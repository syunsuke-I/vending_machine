# frozen_string_literal: true

require_relative '../suica/lib/suica'
require_relative '../suica//lib/drink'
require_relative '../suica//lib/vending_machine'
require_relative '../suica/output'

# ドリンクの初期在庫を設定

vending_machine = VendingMachine.new
suica = Suica.new
suica.charge(2000)

# ドリンクが購入可能か確認か確認
puts vending_machine.check_purchase(suica, 'ペプシ')

# 購入するドリンクを配列に格納する
drink_list_to_buy = %w[ペプシ モンスター いろはす]

# 購入前の残高と売り上げの確認
check_detail_info(vending_machine, suica)

# 購入処理のテスト
do_purchase_drinks(suica, drink_list_to_buy, vending_machine)

# # 購入前の残高と売り上げの確認
check_detail_info(vending_machine, suica)

# 補充のテスト
do_restock('ペプシ', vending_machine, 2)
do_restock('いろはす', vending_machine, 2)

# その他の動作確認
puts '<=======その他のテスト======>'
puts '> STEP 1 残高が0円の時に何も購入できないことの確認'
puts "> 残高は#{suica.balance}"
puts "> 購入可能なドリンク=> #{vending_machine.drinks_list(suica)}"

suica.charge(150) # チャージしたら購入可能なドリンクが増える
puts '> STEP 2 残高が150円の時にモンスター以外が購入できることの確認'
puts "> 残高は#{suica.balance}"
puts "> 購入可能なドリンク=> #{vending_machine.drinks_list(suica)}"

puts do_purchase_drink(suica, 'いろはす', vending_machine)

# # 購入前の残高と売り上げの確認
check_detail_info(vending_machine, suica)
