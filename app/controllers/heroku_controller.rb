class HerokuController < ApplicationController
  before_filter :heroku_authentication, except: :login

  SALT = 'b7LUzvupm7czgm5Q'

  def create
    user = User.active.where(email: params[:heroku_id]).first_or_create!(password: 'helloworld')

    feed = user.feeds.build(name: "application_#{SecureRandom.hex(2)}")

    user.change_plan_to(params[:plan])

    result = {id: user.uuid, config: { STATUSUS_URL: dashboard_url(user.uuid) }}
    render :json => result
  end

  # {
    # "plan"=>"premium",
    # "heroku_id"=>"app7796@kensa.heroku.com",
    #  "id"=>"123",
    # "heroku" => {"plan"=>"premium", "heroku_id"=>"app7796@kensa.heroku.com"}}
  def update
    user = User.active.where(uuid: params[:id]).first!
    user.change_plan_to(params[:plan])

    result = {:message => 'You changed your plan. Thanks!', :config => { "STATUSUS_URL" => dashboard_url(user.uuid) } }
    render :json => result
  end

  def destroy
    User.find_by_uuid(params[:id]).update_attribute(:active, false)
    head :ok
  end

  def login
    signature = Digest::SHA1.hexdigest("#{params[:id]}:#{SALT}:#{params[:timestamp]}")
    if signature != params[:token]
      return head :forbidden
    end

    if params[:timestamp].to_i < 2.minutes.ago.to_i
      return head :forbidden
    end

    user = User.active.where(uuid: params[:id]).first!

    session[:user] = user.id
    session[:heroku_sso] = true
    cookies[:'heroku-nav-data'] = params[:'nav-data']

    redirect_to dashboard_url(user.uuid)
  end

  def heroku_authentication
    authenticate_or_request_with_http_basic do |user, password|
      user == "statusus" && password == "BZ2L1PUcfFp43RVx"
    end
  end
end
