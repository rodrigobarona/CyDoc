class PatientsController < ApplicationController
  in_place_edit_for :vcard, :family_name
  in_place_edit_for :vcard, :given_name
  in_place_edit_for :vcard, :street_address
  in_place_edit_for :vcard, :postal_code
  in_place_edit_for :vcard, :locality
  in_place_edit_for :patient, :birth_date
  in_place_edit_for :patient, :doctor_patient_nr
  in_place_edit_for :patient, :insurance_nr
                
  # CRUD Actions
  def list
    search
  end

  def search
    value = params[:query]
    if value.nil?
      @patients = []
      return
    end
    
    case get_query_type(value)
    when "date"
      value = Date.parse_europe(value).strftime('%%%y-%m-%d')
      patient_condition = "(patients.birth_date LIKE :value)"
    when "entry_nr"
      patient_condition = "(patients.doctor_patient_nr = :value)"
    when "text"
      value = "%#{value}%"
      patient_condition = "(vcards.given_name LIKE :value) OR (vcards.family_name LIKE :value) OR (vcards.full_name LIKE :value)"
    end
    @patients = Patient.find(:all, :include => [:vcards ], :conditions => ["(#{patient_condition}) AND patients.doctor_id IN (:doctor_id)", {:value => value, :doctor_id => @current_doctor_ids}], :limit => 100)

    render :partial => 'list', :layout => false
  end

  private
  def get_query_type(value)
    if value.match(/([[:digit:]]{1,2}\.){2}/)
      return "date"
    elsif value.match(/^([[:digit:]]{0,2}\/)?[[:digit:]]*$/)
      return "entry_nr"
    else
      return "text"
    end
  end

  public
  
  def index
    redirect_to :action => :list
  end
  
  def new
    patient = params[:patient]
    @patient = Patient.new(patient)
    @vcard = Vcards::Vcard.new(params[:vcard])
    @vcard.honorific_prefix = 'Frau'
    @vcard.address = Vcards::Address.new

    @patients = []
    render :action => 'list'
  end

  def create
    @patient = Patient.new(params[:patient])
    @vcard = Vcards::Vcard.new(params[:vcard])
    @patient.vcards << @vcard

    if @patient.save
      flash[:notice] = 'Patient erfasst.'
      redirect_to :action => :show, :id => @patient
    else
      render :action => :new
    end
  end

  def show
    unless Patient.exists?(params[:id])
      render :inline => "<h1>Patient existiert nicht</h1>", :layout => 'application', :status => 404
      return
    end
    
    @patient = Patient.find(params[:id])
    @record_tarmed = RecordTarmed.new
  end

  # Search
  # ======
  def vcard_conditions(vcard_name = 'vcard')
    vcard_params = params[:vcard] || {}
    keys = []
    values = []

    fields = vcard_params.reject { |key, value| value.nil? or value.empty? }
    fields.each { |key, value|
      keys.push "#{vcard_name}.#{key} LIKE ?"
      values.push '%' + value.downcase.gsub(' ', '%') + '%'
    }

    return !keys.empty? ? [ keys.join(" AND "), *values ] : nil
  end

  def patient_conditions
    parameters = params[:patient]
    keys = []
    values = []

    unless parameters[:name].nil? or parameters[:name].empty?
      keys.push "patient_id = ?"
      values.push parameters[:full_name].split(' ')[0].strip
    end

    unless parameters[:doctor_patient_nr].nil? or parameters[:doctor_patient_nr].empty?
      keys.push "doctor_patient_nr = ?"
      values.push parameters[:doctor_patient_nr].strip
    end

    unless parameters[:birth_date].nil? or parameters[:birth_date].empty?
      keys.push "birth_date LIKE ? "
      values.push Date.parse_europe(parameters[:birth_date]).strftime('%%%y-%m-%d')
    end

    return !keys.empty? ? [ keys.join(" AND "), *values ] : nil
  end


  def old_search
    keys = []
    values = []
    
#    default_vcard_keys, *default_vcard_values = vcard_conditions('vcards')
#    billing_vcard_keys, *billing_vcard_values = vcard_conditions('billing_vcards_patients')
    
#    unless default_vcard_keys.nil?
#      keys.push "( ( #{default_vcard_keys} ) )"
#      values.push *default_vcard_values
#      values.push *billing_vcard_values
#    end
    
#    patient_keys, *patient_values = patient_conditions
#    keys.push patient_keys
#    values.push *patient_values
    
    # Build conditions array
#    if keys.compact.empty?
#      @patients = []
#    else
#      conditions = !keys.compact.empty? ? [  keys.compact.join(" AND "), *values ] : nil
#      @patients = Patient.find :all, :conditions => conditions, :include => [:vcard => [:address], :billing_vcard => [:address]], :order => 'vcards.family_name'
#    end

    if !(params[:patient][:name].nil? or params[:patient][:name].empty?)
      @patients = Patient.by_name(params[:patient][:name])
    elsif !(params[:patient][:birth_date].nil? or params[:patient][:birth_date].empty?)
      @patients = Patient.by_date(params[:patient][:birth_date])
    else
      @patients = []
    end

    render :partial => 'search_result'
  end
  
  # Services
  def list_services
    @patient = Patient.find(params[:id])
    render :partial => 'tariff_items/list', :locals => {:items => @patient.record_tarmeds}
  end

  def delete_service
    RecordTarmed.destroy(params[:id])
    redirect_to :action => 'list_services'
  end
end
