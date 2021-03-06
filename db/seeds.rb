# General Seeds
# =============
HonorificPrefix.create!([
  {:sex => 1, :position => 1, :name => 'Herr'},
  {:sex => 1, :position => 2, :name => 'Herr Dr.'},
  {:sex => 1, :position => 3, :name => 'Herr Dr. med.'},
  {:sex => 1, :position => 4, :name => 'Herr Prof.'},
  {:sex => 2, :position => 1, :name => 'Frau'},
  {:sex => 2, :position => 2, :name => 'Frau Dr.'},
  {:sex => 2, :position => 3, :name => 'Frau Dr. med.'},
  {:sex => 2, :position => 4, :name => 'Frau Prof.'}
])

VatClass.create!([
  {:code => "excluded", :rate => 0.0, :valid_from => '2001-01-01'},
  {:code => "reduced", :rate => 2.4, :valid_from => '2001-01-01'},
  {:code => "full", :rate => 7.6, :valid_from => '2001-01-01'}
])

# Demo Seeds
# ==========
doctor = Doctor.create!(
  :vcard => Vcard.new(
    :honorific_prefix => 'Frau Dr. med.',
    :family_name => "Muster",
    :given_name => "Melanie",
    :street_address => "Zentralgasse 99",
    :postal_code => "6300",
    :locality => "Zug"
  )
)

user = User.create!(
  :name => "Demo Benützer", :login => "doctor", :password => "doctor1234", :password_confirmation => "doctor1234", :email => "cydoc-demo@cyt.ch"
)
user.object = doctor
user.register!
user.activate!

doctor.offices.create!(
  :name => "Demo Praxis",
  :printers => {:cups_host=>"localhost", :trays=>{:invoice=>"invoice_tray", :label=>"label_tray", :plain=>"plain_tray"}}
)

# Accounting
bank = Bank.create!(
  :vcard => Vcard.new(
    :full_name => "General Bank",
    :street_address => "Hauptstrasse 1",
    :postal_code => "8000",
    :locality => "Zürich"
  )
)

doctor.accounts << BankAccount.create!([
  {:pc_id => "01-123456-7", :esr_id => "444444", :code => "1020", :title => "Bankkonto", :bank => bank, :holder => doctor}
])

doctor.accounts << Account.create!([
  {:code => "1000", :title => "Kasse"},
  {:code => "1100", :title => "Debitoren"},
  {:code => "1210", :title => "Lager Medikamente"},
  {:code => "3200", :title => "Dienstleistungsertrag"},
  {:code => "3900", :title => "Debitorenverlust"},
  {:code => "4000", :title => "Aufwand Medikamente"},
  {:code => "8000", :title => "Ausserordentlicher Ertrag"}
])
