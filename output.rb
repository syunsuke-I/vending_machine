# frozen_string_literal: true

# 出力系の処理をまとめています
# このメソッド類を使用せずとも処理は行えますが確認を行いやすくするために作成しました

# 購入処理と購入後の在庫数を表示する処理をまとめた
def do_purchase_drink(suica, drink_name, vending_machine)
  puts '<========= 購入処理 =========>'
  puts vending_machine.purchase(suica, drink_name)
  check_stock(drink_name, vending_machine)
end

# 購入処理と購入後の在庫数を表示する処理をまとめた
def do_purchase_drinks(suica, drink_list, vending_machine)
  puts '<========= 購入処理 =========>'
  drink_list.each do |drink_name|
    puts vending_machine.purchase(suica, drink_name)
    check_stock(drink_name, vending_machine)
  end
end

# 補充処理と補充後の在庫数を表示する処理をまとめた
def do_restock(drink_name, vending_machine, quantity)
  puts '<========= 補充処理 =========>'
  vending_machine.restock(drink_name, quantity)
  puts "> #{drink_name}の補充が完了しました\n> 補充したのは#{quantity}個です"
  check_stock(drink_name, vending_machine)
end

# 売上とSuicaの残高を確認する文言を出力
def check_detail_info(vending_machine, suica)
  puts '<======== 売上/残高 ========>'
  puts "売上(自販機)               : #{vending_machine.sales_amount}"
  puts "残高(Suica)                : #{suica.balance}"
end

# 在庫を確認する文言を出力
def check_stock(drink_name, vending_machine)
  stock = vending_machine.check_stock(drink_name)
  puts "・#{drink_name}の在庫は#{stock}個です"
end

public

def check_purchase(suica, drink_name)
  puts '<======== 購入確認 ========>'
  is_purchaseable, error_msg = purchase?(suica, drink_name)
  drink = @drinks.find { |d| d.name == drink_name }
  _msg = if is_purchaseable
           "> #{drink.name}は購入可能です"
         else
           "> #{drink.name}は#{error_msg}のため\n  購入できません"
         end
end

