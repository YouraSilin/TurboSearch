class PhonesController < ApplicationController
  include ActionView::RecordIdentifier

  before_action :set_phone, only: %i[ show edit update destroy ]
  before_action :authorize_admin, only: [:create, :edit, :update, :destroy]

  def authorize_admin
    redirect_to phones_path, alert: 'У вас нет прав для этого действия.' unless current_user&.admin?
  end

  # GET /phones or /phones.json
  def index
    respond_to do |format|
      format.html do
        if params[:query].present?
          query = "%#{params[:query]}%"
          @phones = fetch_phones
        else
          @phones = fetch_phones
        end
      end
      format.xlsx do
        @phones = Phone.order(:created_at)
        render xlsx: 'Телефоны', template: 'phones/phone'
      end
    end
  end

  # Импорт телефонов
  def import
    Phones::Import.call(params[:file])
    redirect_to phones_path, notice: "#{$phones_imported_count} строк импортировано"
  end

  # Удаление всех телефонов
  def delete_all
    Phone.destroy_all
    redirect_to phones_path, notice: 'Все телефоны успешно удалены.'
  end

  # GET /phones/1 or /phones/1.json
  def show
  end

  # GET /phones/new
  def new
    @phone = Phone.new
  end

  # GET /phones/1/edit
  def edit
    @phone = Phone.find(params[:id])
  end

  # POST /phones or /phones.json
  def create
    @phone = Phone.new(phone_params)

    respond_to do |format|
      if @phone.save
        format.html { redirect_to phones_path, notice: "Запись сохранена" }
        format.json { render :show, status: :created, location: @phone }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @phone.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /phones/1 or /phones/1.json
  def update
    @phone = Phone.find(params[:id]) # Найдем телефон по его ID
    respond_to do |format|
      if @phone.update(phone_params)
        format.html { redirect_to phones_path, notice: "Запись сохранена" }
        format.json { render :show, status: :ok, location: @phone }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @phone.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /phones/1 or /phones/1.json
  def destroy
    @phone = Phone.find(params[:id])
    @phone.destroy
    redirect_to phones_path, notice: "Запись удалена"
  end

  private

    def set_phone
      @phone = Phone.find(params[:id])
    end

    def phone_params
      params.require(:phone).permit(:department, :name, :position, :number, :mobile, :mail)
    end

    def fetch_phones
      phones = Phone.all
      
      # Фильтр по департаменту
      phones = phones.where(department: params[:department]) if params[:department].present?
      
      # Поиск
      phones = search_query(phones) if params[:query].present?
      
      # Сортировка: сначала с внутренним номером, потом без
      phones = phones.order(
        Arel.sql('CASE WHEN phones.number IS NOT NULL THEN 0 ELSE 1 END ASC'),
        Arel.sql('number ASC NULLS LAST'),
        :name
      )
    end
    
    def search_query(phones)
      query = "%#{params[:query]}%"
      phones.where("department ILIKE :query OR name ILIKE :query OR position ILIKE :query OR number ILIKE :query OR mobile ILIKE :query OR mail ILIKE :query", query: query)
    end

end