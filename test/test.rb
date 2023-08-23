# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/drink'
require_relative '../lib/vending_machine'
require_relative '../lib/suica'

# テスト用
class SuicaTest < Minitest::Test
  def test_suica_step_one
    # 預かり金(デポジット)として500円がデフォルトでチャージされているものとする
    suica = Suica.new
    assert_equal 500, suica.balance

    # Suicaには100円以上の任意の金額をチャージできる
    # Suicaは現在のチャージ残高を取得できる
    suica.charge(100)
    assert_equal 600, suica.balance

    # 100円未満をチャージしようとした場合は例外を発生させる
    e = assert_raises RuntimeError do
      suica.charge(50)
    end
    assert_equal e.message, '100円以上チャージしてください'
  end

  def test_suica_step_two
    # 自動販売機はジュースを１種類格納できる
    # 後で3種類に変わるので省略

    # ジュースは名前と値段の情報をもつ
    pepsi = Drink.new('いろはす', 120)
    assert_equal 'いろはす', pepsi.name
    assert_equal 120, pepsi.price

    # 初期状態で、ペプシ(150円)を5本格納している。
    # 自動販売機は在庫を取得できる
    vending_machine = VendingMachine.new
    assert_equal 5, vending_machine.check_stock('ペプシ')
  end

  def test_suica_step_three
    # 自動販売機はペプシが購入できるかどうかを取得できる。
    vending_machine = VendingMachine.new
    assert vending_machine.check_stock('ペプシ')

    # ジュース値段以上のチャージ残高がある条件下で購入操作を行うと以下の動作をする
    suica = Suica.new
    vending_machine.purchase(suica, 'ペプシ')
    assert_equal 4, vending_machine.check_stock('ペプシ') # 自動販売機はジュースの在庫を減らす 5-1
    assert_equal 150, vending_machine.sales_amount       # 売り上げ金額を増やす 0+150
    assert_equal 350, suica.balance                      # Suicaのチャージ残高を減らす 500-150

    # チャージ残高が足りない場合もしくは在庫がない場合、購入操作を行った場合は例外を発生させる
    vending_machine.purchase(suica, 'モンスター') # 350-230 = 120
    e = assert_raises RuntimeError do
      vending_machine.purchase(suica, 'ペプシ') # チャージ残高が足りない場合 (120-150 = -30)
    end
    assert_equal e.message, '残高不足'

    suica.charge(1880) # 在庫不足を発生させるためにチャージ
    vending_machine.purchase(suica, 'いろはす')
    vending_machine.purchase(suica, 'いろはす')
    vending_machine.purchase(suica, 'いろはす')
    vending_machine.purchase(suica, 'いろはす')
    vending_machine.purchase(suica, 'いろはす')

    e = assert_raises RuntimeError do
      vending_machine.purchase(suica, 'いろはす')
    end
    assert_equal e.message, '在庫不足' # 在庫がない場合

    # 自動販売機は現在の売上金額を取得できる
    assert !vending_machine.sales_amount.nil?
  end

  def test_suica_step_four
    # ジュースを3種類管理できるようにする。
    vending_machine = VendingMachine.new
    suica = Suica.new
    assert_equal 5, vending_machine.check_stock('モンスター') # 初期状態で5本格納されているか
    assert_equal 5, vending_machine.check_stock('いろはす') # 初期状態で5本格納されているか
    vending_machine.purchase(suica, 'モンスター') # 値段の確認を行うが初期で追加されるものの値段を調べることができないので購入後の残高で検証
    assert_equal 270, suica.balance # 500-230
    vending_machine.purchase(suica, 'いろはす') # 値段の確認を行うが初期で追加されるものの値段を調べることができないので購入後の残高で検証
    assert_equal 150, suica.balance # 270-120

    # 自動販売機は購入可能なドリンクのリストを取得できる
    assert_equal %w[ペプシ いろはす], vending_machine.drinks_list(suica) # 残高150で買えるもの
    suica.charge(1000)
    assert_equal %w[ペプシ モンスター いろはす], vending_machine.drinks_list(suica) # 残高1150で買えるもの

    # 自動販売機に在庫を補充できるようにする
    vending_machine.check_stock('いろはす') # 4
    vending_machine.restock('いろはす', 2)
    assert_equal 6, vending_machine.check_stock('いろはす')

    # ステップ3と同様の方法でモンスターといろはすを購入できる
    # 83行目 85行目で確認済
  end

  def test_suica_deduct
    suica = Suica.new
    e = assert_raises RuntimeError do
      suica.deduct(501)
    end
    assert_equal e.message, '残高不足です'
    assert_equal 0, suica.deduct(500)
    suica.charge(500)
    assert_equal 1, suica.deduct(499)
  end
end

