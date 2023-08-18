# frozen_string_literal: true

# 飲み物を管理するクラス
class Drink
  # 自動販売機は在庫を取得できる
  attr_reader :price, :name

  # ジュースは名前と値段の情報をもつ
  def initialize(name, price)
    @name = name
    @price = price
  end
end
