class WakeupController < ApplicationController
  def show
    render plain: "Ok! I'm up!"
  end
end
