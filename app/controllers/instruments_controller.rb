class InstrumentsController < ApplicationController
  # GET /instruments
  def index
    @instruments = current_user.instruments
  end

  # GET /instruments/1
  def show
    @instrument = Instrument.find(params[:id])
  end

  # GET /instruments/new
  def new
    @data_types = DataType.all
    @instrument = Instrument.new
    @locations = current_user.locations
    if current_user.instruments.empty?
      flash[:notice] = t 'instruments.new.add_instrument_notice'
    end
  end

  # GET /instruments/1/edit
  def edit
    @instrument = Instrument.find(params[:id])
  end

  # POST /instruments
  def create
    @instrument = Instrument.create(params[:instrument])
    current_user.instruments << @instrument
    if @instrument.valid?
      redirect_to instruments_path,
        :notice => t('instruments.create.successful')
    else
      render :action => "new"
    end
  end

  # PUT /instruments/1
  def update
    @instrument = Instrument.find(params[:id])
    if @instrument.update_attributes(params[:instrument])
      redirect_to(@instrument, :notice => 'Instrument was successfully updated.')
    else
      render :action => "edit"
    end
  end

  # DELETE /instruments/1
  def destroy
    @instrument = Instrument.find(params[:id])
    @instrument.destroy
    redirect_to(instruments_url)
  end
end
