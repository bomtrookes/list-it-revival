# Lets visitors try List-It with one click, signed in as the shared demo account.
class DemoSessionsController < ApplicationController
  skip_before_action :authenticate_user!

  def create
    demo = User.demo_user
    if demo
      sign_in(demo)
      redirect_to root_path, notice: "You're exploring the demo account. Changes are reset regularly."
    else
      redirect_to root_path, alert: "The demo isn't set up yet."
    end
  end
end
