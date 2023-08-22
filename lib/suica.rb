# frozen_string_literal: true

# Suicaを扱うクラス
class Suica
  # Suicaは現在のチャージ残高を取得できる
  attr_reader :balance

  # 預かり金(デポジット)として500円がデフォルトでチャージされているものとする
  def initialize
    @balance = 500
  end

  # Suicaには100円以上の任意の金額をチャージできる

  def charge(amount)
    # 100円未満をチャージしようとした場合は例外を発生させる
    raise '100円以上チャージしてください' if amount < 100

    @balance += amount
  end

  def deduct(amount)
    @balance -= amount
  end
end

