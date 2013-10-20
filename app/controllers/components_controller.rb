class ComponentsController < ApplicationController
  before_filter :authorize

  before_action :set_component, only: [:show, :edit, :update, :status, :destroy]

  # GET /components
  def index
    @components = current_user.components
  end

  # GET /components/new
  def new
    @component = current_user.components.build
  end

  # GET /components/1/edit
  def edit
  end

  # POST /components
  def create
    @component = current_user.components.build(component_params)

    if @component.save
      redirect_to components_path, notice: 'Component was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /components/1
  def update
    if @component.update(component_params)
      redirect_to components_path, notice: 'Component was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def status
    @component.status = params[:status].to_i
    if @component.save
      render json: 'Done'
    else
      render json: {errors: @component.errors.full_messages}
    end
  end

  # DELETE /components/1
  def destroy
    @component.destroy
    redirect_to components_url, notice: 'Component was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_component
      @component = current_user.components.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def component_params
      params.require(:component).permit(:name)
    end
end
