# frozen_string_literal: true

# ============================================================
# Seeds de desenvolvimento — Casa do Celular
# Idempotente: rode quantas vezes quiser sem duplicar dados.
# Login padrão: fashion.store@email.com / 123456
# ============================================================

# ── 1. Usuário / Conta principal ───────────────────────────
Rails.logger.debug '→ Criando usuário principal...'

user = User.find_or_initialize_by(email: 'fashion.store@email.com')
if user.new_record?
  user.first_name   = 'Casa'
  user.last_name    = 'Celular'
  user.company_name = 'Casa do Celular LTDA'
  user.cpf_cnpj     = '12345678000190'
  user.phone        = '81999990000'
  user.password     = '123456'
  user.save!
  Rails.logger.debug "  Usuário criado: #{user.email}"
else
  Rails.logger.debug "  Usuário já existe: #{user.email}"
end

user2 = User.find_or_initialize_by(email: 'stock@email.com')
if user2.new_record?
  user2.first_name   = 'Estoque'
  user2.last_name    = 'Admin'
  user2.company_name = 'Casa do Celular LTDA'
  user2.cpf_cnpj     = '98765432000111'
  user2.phone        = '81999991111'
  user2.password     = '123456'
  user2.save!
  Rails.logger.debug "  Usuário criado: #{user2.email}"
end

account = user.account
Rails.logger.debug "  Conta: #{account.id} — #{account.company_name}"

# ── 2. Feature Bling (necessária para o app não reclamar) ──
Rails.logger.debug '→ Configurando feature Bling...'

bling_datum = BlingDatum.find_or_initialize_by(account_id: account.id)
if bling_datum.new_record?
  bling_datum.expires_at     = Time.zone.now + 1.year
  bling_datum.access_token   = ENV.fetch('ACCESS_TOKEN', 'dev_token')
  bling_datum.refresh_token  = ENV.fetch('REFRESH_TOKEN', 'dev_refresh')
  bling_datum.save!
end

feature = Feature.find_or_create_by!(feature_key: FeatureKey::BLING_INTEGRATION) do |f|
  f.is_enabled = true
end

unless account.features.include?(feature)
  account.features << feature
  account.account_features.find_by(feature: feature)&.update(is_enabled: true)
end

# ── 3. Categorias de celulares (com NCM) ───────────────────
Rails.logger.debug '→ Criando categorias...'
load Rails.root.join('db/seeds/celulares_categories.rb')

# ── 4. Clientes de exemplo ─────────────────────────────────
Rails.logger.debug '→ Criando clientes...'

SAMPLE_CUSTOMERS = [
  { name: 'João Silva',     email: 'joao.silva@email.com',     phone: '8130001001', cellphone: '81999110001', cpf: '111.222.333-44' },
  { name: 'Maria Oliveira', email: 'maria.oliveira@email.com', phone: '8130002002', cellphone: '81999220002', cpf: '222.333.444-55' },
  { name: 'Carlos Pereira', email: 'carlos.p@email.com',       phone: '8130003003', cellphone: '81999330003', cpf: '333.444.555-66' },
  { name: 'Ana Costa',      email: 'ana.costa@email.com',       phone: '8130004004', cellphone: '81999440004', cpf: '444.555.666-77' },
  { name: 'Pedro Santos',   email: 'pedro.s@email.com',         phone: '8130005005', cellphone: '81999550005', cpf: '555.666.777-88' }
].freeze

ActsAsTenant.with_tenant(account) do
  SAMPLE_CUSTOMERS.each do |attrs|
    Customer.find_or_create_by!(email: attrs[:email], account_id: account.id) do |c|
      c.name      = attrs[:name]
      c.phone     = attrs[:phone]
      c.cellphone = attrs[:cellphone]
      c.cpf       = attrs[:cpf]
    end
  end
end
Rails.logger.debug "  #{SAMPLE_CUSTOMERS.size} clientes verificados."

# ── 5. Fornecedores de exemplo ─────────────────────────────
Rails.logger.debug '→ Criando fornecedores...'

SAMPLE_SUPPLIERS = ['Samsung Brasil', 'Apple Brasil', 'Xiaomi Brasil', 'Motorola', 'Multilaser'].freeze

ActsAsTenant.with_tenant(account) do
  SAMPLE_SUPPLIERS.each do |name|
    Supplier.find_or_create_by!(name: name, account_id: account.id)
  end
end
Rails.logger.debug "  #{SAMPLE_SUPPLIERS.size} fornecedores verificados."

# ── 6. Produtos / PhoneUnits de exemplo ────────────────────
Rails.logger.debug '→ Criando produtos de celular...'

smartphones_cat = Category.find_by(name: 'Smartphones', account_id: account.id)

SAMPLE_PHONES = [
  { name: 'Samsung Galaxy S23',    brand: 'Samsung', phone_model: 'Galaxy S23',    storage_gb: 128, ram_gb: 8,  color: 'Preto',  condition: 'novo',     price: 3_499.90 },
  { name: 'iPhone 14',             brand: 'Apple',   phone_model: 'iPhone 14',     storage_gb: 128, ram_gb: 6,  color: 'Azul',   condition: 'seminovo', price: 4_199.90 },
  { name: 'Xiaomi Redmi Note 12',  brand: 'Xiaomi',  phone_model: 'Redmi Note 12', storage_gb: 128, ram_gb: 6,  color: 'Cinza',  condition: 'novo',     price: 1_299.90 },
  { name: 'Motorola Edge 30',      brand: 'Motorola',phone_model: 'Edge 30',       storage_gb: 256, ram_gb: 8,  color: 'Prata',  condition: 'novo',     price: 2_199.90 }
].freeze

ActsAsTenant.with_tenant(account) do
  SAMPLE_PHONES.each_with_index do |attrs, idx|
    product = Product.find_or_initialize_by(name: attrs[:name], account_id: account.id)
    if product.new_record?
      product.assign_attributes(
        brand:      attrs[:brand],
        phone_model: attrs[:model_name],
        storage_gb: attrs[:storage_gb],
        ram_gb:     attrs[:ram_gb],
        color:      attrs[:color],
        condition:  attrs[:condition],
        price:      attrs[:price],
        category:   smartphones_cat,
        active:     true
      )
      product.save!

      # Cria uma unidade física (PhoneUnit) com IMEI único
      imei_base = 356_938_000_000_000
      PhoneUnit.find_or_create_by!(imei1: (imei_base + idx).to_s, account_id: account.id) do |pu|
        pu.product        = product
        pu.status         = 'em_estoque'
        pu.condition      = attrs[:condition]
        pu.color          = attrs[:color]
        pu.purchase_price = (attrs[:price] * 0.7).round(2)
        pu.sale_price     = attrs[:price]
      end
      Rails.logger.debug "  Produto criado: #{product.name}"
    end
  end
end

# ── 7. OS de exemplo ───────────────────────────────────────
Rails.logger.debug '→ Criando OS de exemplo...'

ActsAsTenant.with_tenant(account) do
  customer = Customer.find_by(account_id: account.id)
  if customer
    so = ServiceOrder.find_or_initialize_by(account_id: account.id, reported_defect: 'Tela quebrada — seed')
    if so.new_record?
      so.customer    = customer
      so.status      = 'aberta'
      so.device_brand = 'Samsung'
      so.device_model = 'Galaxy S23'
      so.device_imei  = '356938000000099'
      so.labor_cost   = 150.0
      so.save!
      so.service_order_items.find_or_create_by!(description: 'Tela AMOLED') do |item|
        item.quantity   = 1
        item.unit_price = 280.0
      end
      Rails.logger.debug "  OS #{so.number} criada."
    end
  end
end

Rails.logger.debug '✓ Seeds concluídos!'
