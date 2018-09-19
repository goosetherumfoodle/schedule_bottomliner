class WakeupController < ApplicationController
  def create
    render plain: "Ok! I'm up!"
  end
end
