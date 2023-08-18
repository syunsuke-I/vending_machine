# frozen_string_literal: true

require_relative '../lib/drink'

# frozen_string_literal: true

# 自動販売機
class VendingMachine
  attr_reader :sales_amount, :drinks
  attr_writer :drinks

  def initialize
    @sales_amount = 0
    @drinks = []
    @drinks_data = {}
    @stock = 0
    add_drink_ini
  end

  def add_drink_ini
    add_drinks(Array.new(5) { Drink.new('ペプシ', 150) })
    add_drinks(Array.new(5) { Drink.new('モンスター', 230) })
    add_drinks(Array.new(5) { Drink.new('いろはす', 120) })
  end

  def add_drinks(drinks)
    drinks.each do |drink|
      add_drink(drink)
    end
  end

  def add_drink(drink)
    @drinks.push(drink)
    @drinks_data.store(drink.name, drink.price)
  end

  def check_stock(drink_name)
    @drinks.count { |d| d.name == drink_name }
  end

  def get_min_index(drink_name)
    _index = @drinks.index { |d| d.name == drink_name }
  end

  def get_drink_data_by_name(drink_name)
    drink = @drinks_data.uniq.find { |k, _v| k == drink_name }
    Drink.new(drink[0], drink[1])
  end

  def find_drink_by_name(drink_name)
    _drink = @drinks.find { |d| d.name == drink_name }
  end

  # 補充する際に新規のドリンクか元々存在していたかの区別が必要なため
  def does_exist?(drink_name)
    drink = @drinks_data.find { |k, _v| k == drink_name }
    drink.nil? ? false : true
  end

  def reduce_stock(drink)
    stock = check_stock(drink.name)
    raise '在庫がありません。' if stock.zero?

    index_to_delete = get_min_index(drink.name)
    drinks.delete_at(index_to_delete)
  end

  # 自動販売機は購入可能なドリンクのリストを取得できる
  def drinks_list(suica)
    purchasable_drink = @drinks.map { |drink| drink.name if drink.price <= suica.balance }.compact
    purchasable_drink.empty? ? '存在しません' : purchasable_drink.uniq
  end

  # 自動販売機に在庫を補充できるようにする
  def restock(drink_name, quantity)
    add_drinks(Array.new(quantity) { get_drink_data_by_name(drink_name) }) if does_exist?(drink_name)
    raise "#{drink_name}は存在しません" unless does_exist?(drink_name)
  end

  def purchase(suica, drink_name)
    is_purchaseable, error_msg = purchase?(suica, drink_name)
    if is_purchaseable
      drink = @drinks[get_min_index(drink_name)]
      reduce_stock(drink) # 自動販売機はジュースの在庫を減らす
      @sales_amount += drink.price # 売り上げ金額を増やす
      suica.deduct(drink.price) # Suicaのチャージ残高を減らす
      _msg = "> #{drink.name}の購入が成功しました"
    else
      _msg = "> #{error_msg}\n> 購入が失敗しました"
    end
  end

  def purchase?(suica, drink_name)
    error_msg = []
    if !does_exist?(drink_name) # そもそも存在しない場合はメッセージを出力
      error_msg.push("#{drink_name}は存在しません")
    else
      drink = get_drink_data_by_name(drink_name)
      # チャージ残高が足りない場合もしくは在庫がない場合、購入操作を行った場合は例外を発生させる
      raise '残高不足' if suica.balance < drink.price
      raise '在庫不足' if check_stock(drink.name) <= 0
    end

    [error_msg.empty?, error_msg]
  end
end
