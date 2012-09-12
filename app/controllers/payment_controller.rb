class PaymentController < ApplicationController
  protect_from_forgery :except => :checkout

  def checkout
    ecard = Ecard.find(params[:ecard_id])
    price = (ecard.price * 100).round

    response = PAYPAL_EXPRESS.setup_purchase(
      price,
      :ip => request.remote_ip,
      :return_url => url_for(:action => :complete, :only_path => false),
      :cancel_return_url => url_for(:action => :cancel, :only_path => false),
      :items => [
        {
            :name => ecard.title,
            :quantity => 1,
            :amount => ecard.price
        }
      ]
    )

    SentEcard.create(
        :recipientemail => params[:recipient_email],
        :recipientname => params[:recipient_name],
        :message1 => params[:message1],
        :message2 => "",
        :nametoshow => params[:sender_name],
        :senderemail => params[:sender_email],
        :ecard_id => params[:ecard_id],
        :securelink => new_secure_link("#{Time.now.utc}--#{params[:recipient_email]}"),
        :sent => false,
        :pay_key => response.token
    )

    redirect_to PAYPAL_EXPRESS.redirect_url_for(response.token)
  rescue ActiveRecord::RecordNotFound
    logger.error("Ecard with ID #{params[:ecard_id]} not found!")
  end

  def confirm
  end

  def complete
    # Cannot complete this request if we have missing parameters...
    return render :status => :bad_request if params[:token] == nil

    # Load models...
    sent_ecard = SentEcard.find_by_pay_key!(params[:token])
    ecard = Ecard.find(sent_ecard.ecard_id)

    price = (ecard.price * 100).round

    details = PAYPAL_EXPRESS.details_for(params[:token])

    response = PAYPAL_EXPRESS.purchase(
        price,
        :ip => request.remote_ip,
        :payer_id => details.payer_id,
        :token => params[:token]
    )

    if response.success?
      recipients = sent_ecard.recipientemail.split(",")
      names = sent_ecard.recipientname.split(",")

      emails = []

      recipients.each_with_index do |recip, idx|
        if names[idx] != nil then
          emails << "#{names[idx].strip} <#{recip.strip}>"
        else
          emails << recip.strip
        end
      end

      content = {
          :link => sent_ecard.securelink,
          :senderemail => sent_ecard.senderemail,
          :sendername => sent_ecard.nametoshow,
          :image => ecard.image,
          :email => emails.join(", "),
          :recipient_name => names
      }

      CodeNotifier.recipient(content).deliver

      sent_ecard.update_attributes(:sent => true)

      redirect_to transaction_complete_url
    else
      logger.error(response.message)
      render :status => :payment_required
    end
  rescue ActiveRecord::RecordNotFound
    render :status => :not_found
  end

  def cancel

  end

  private

  def new_secure_link(string)
    Digest::SHA2.hexdigest(string)
  end
end
