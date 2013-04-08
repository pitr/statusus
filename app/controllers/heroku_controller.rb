class HerokuController < ApplicationController
  before_filter :heroku_authentication

  def create
    user = User.where(email: params[:heroku_id]).first_or_create!(password: 'helloworld')
    #need a way to capture the user application name, not sure if heroku sends it
    feed = user.feeds.build({ :name => "application#{rand(6)}"})
    result = {:id => user.uuid, :config => { "STATUSUS_URL" => dashboard_url(user.uuid) } }
    render :json => result
  end

  def destroy
    User.find_by_uuid(params[:id]).destroy
    render :nothing => true
  end

  def heroku_authentication
    authenticate_or_request_with_http_basic do |user, password|
      user == "statusus" && password == "BZ2L1PUcfFp43RVx"
    end
  end
end
