class AttachmentsController < ApplicationController
  inherit_resources

  belongs_to :doctor, :polymorphic => true, :optional => true

  def create
    create! {
      redirect_to :back
      return
    }
  end

  def download
    @attachment = Attachment.find(params[:id])

    path = @attachment.file.current_path
    send_file path
  end

  # Inherited Resources
  protected
    def collection
      instance_eval("@#{controller_name.pluralize} ||= end_of_association_chain.paginate(:page => params[:page], :per_page => params[:per_page])")
    end
end
