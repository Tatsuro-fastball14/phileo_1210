# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...


# テーブル設計

## users テーブル

| Column                 | Type              | Options     |
| ------------------    | ------             | ----------- |
| email                  |  string           | null: false,unique: ture |
| encrypted_password     | string            | null: false |

-has_one :purchase

## cooksテーブル

| Column               | Type            | Options                        |
| ------               | ----------      | ------------------------------ |
| title                | string          | null: false,                   |
| store                | string          | null: false,                   |
| cook sentence        | string          | null: false,                   |




## purchases テーブル

| Column             | Type       | Options                        |
| -------            | ---------- | ------------------------------ |
| user               | references | null: false, foreign_key: true |
| plan(getugaku)     | integer         | null: false,                   |
| plan(nenngaku)     | integer         | null: false,                   |

-belonges_to :user



