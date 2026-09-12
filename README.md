# Hotel Admin Dashboard

ホテル運営に必要な情報を一元管理するための、ASP.NET Web Forms ベースのホテル管理ダッシュボードです。

本システムでは、ゲスト情報、予約情報、チェックイン状況、客室状況、売上情報などを管理できます。

管理者がホテル全体の状態を素早く確認し、日常業務を効率的に行えることを目的としています。


## 主な機能

- 管理者ログイン
- ダッシュボードによるホテル全体状況の確認
- ゲスト情報の登録・編集・削除
- ゲスト検索
- 予約情報の登録・一覧表示・管理
- チェックイン処理
- 現在宿泊中のゲスト確認
- 客室一覧・客室ステータス管理
- 空室・利用中・予約済み客室数の確認
- チェックアウト遅延予約の確認
- 月別・年別売上レポート
- 前年比の確認
- ゲスト一覧・予約一覧のページネーション


## 使用技術

本プロジェクトでは以下の技術を使用しています。

- ASP.NET Web Forms
- C#
- .NET Framework 4.8
- Microsoft SQL Server / SQL Server LocalDB
- HTML
- CSS
- JavaScript
- SQL Stored Procedure
- Visual Studio
- IIS Express


## プロジェクト構成

機能ごとにページを整理しています。

```text
Pages/
├── Bookings/
│   ├── Booking.aspx
│   ├── BookingsList.aspx
│   ├── CheckIn.aspx
│   ├── CheckInsList.aspx
│   └── OverdueCheckouts.aspx
│
├── Guests/
│   ├── AddGuest.aspx
│   ├── CurrentGuests.aspx
│   └── GuestList.aspx
│
├── Rooms/
│   └── Rooms.aspx
│
└── Reports/
    └── SalesReport.aspx

認証関連ページはルート直下に配置しています。

Login.aspx
Login.aspx.cs
Login.aspx.designer.cs

Register.aspx
Register.aspx.cs
Register.aspx.designer.cs

Register.aspx は初期セットアップ時の管理者作成用です。

通常の管理画面から新規登録ページへのリンクは表示しません。

ダッシュボードや共通ページもルート直下に配置しています。

Default.aspx
Default.aspx.cs
Default.aspx.designer.cs

About.aspx
Contact.aspx

Site.Master
Site.Mobile.Master
Web.config
Global.asax
ログイン

管理画面へのアクセスには管理者ログインが必要です。

主な機能：

管理者ログイン
セッションによるログイン状態管理
未ログイン時のログイン画面へのリダイレクト
ログアウト

通常利用時は Login.aspx からログインします。

開発・動作確認用ログイン情報

開発環境・動作確認用の管理者アカウントは以下です。

ユーザー名: cappy
パスワード: cappy123

Login.aspx から上記のアカウントでログインしてください。

注意
このログイン情報は開発・デモ環境専用です。
GitHub リポジトリを公開する場合は、実際に使用している本番用パスワードを記載しないでください。

ダッシュボード

ダッシュボードではホテルの主要な情報をまとめて確認できます。

表示内容の例：

総予約数
本日のチェックイン数
空室数
利用中客室数
予約済み客室数
月間売上
現在宿泊中のゲスト
チェックアウト遅延情報

ダッシュボード上の各カードから、関連する管理画面へ移動できます。

ゲスト管理

ゲスト管理画面では登録済みゲストの情報を管理できます。

主な機能：

新規ゲスト登録
ゲスト情報編集
ゲスト削除
名前・メールアドレス・電話番号による検索
過去の予約件数表示
10件単位のページネーション

過去の予約履歴が存在するゲストを削除する場合は、予約履歴を保持するため、ゲスト情報を匿名化します。

予約・チェックイン管理

予約管理では宿泊予約の登録や確認を行います。

主な機能：

予約登録
予約一覧表示
予約ステータス確認
チェックイン処理
チェックイン済み予約一覧
チェックアウト遅延予約の確認

チェックイン時にはゲスト情報と客室情報を確認し、予約情報の登録と客室ステータスの更新を行います。

客室管理

客室管理画面ではホテル内の客室をフロアごとに確認できます。

主な客室ステータス：

Available：空室
Occupied：利用中
Reserved：予約済み

客室タイプごとに料金と定員を設定しています。

売上レポート

売上レポートでは、チェックアウト済み予約をもとに売上情報を確認できます。

主な内容：

年間売上
月別売上
月別予約件数
年度切り替え
前年比較
過去年度データの確認
データベースセットアップ

このプロジェクトでは、hoteladmin という名前のローカル SQL Server データベースを使用します。

リポジトリに含まれている SQL ファイルを順番に実行することで、開発環境用のデータベースを作成できます。

必要な環境

以下をインストールしてください。

Visual Studio
.NET Framework 4.8
SQL Server LocalDB または SQL Server Express
SQL Server Management Studio（SSMS）
データベース関連ファイル
Database/
├── Migrations/
│   ├── 001_InitialSchema.sql
│   └── 002_CreateStoredProcedures.sql
│
├── Seeds/
│   ├── 001_DevelopmentData.sql
│   └── 002_SalesReportDemoData.sql
│
└── README.md
各SQLファイルの役割
001_InitialSchema.sql

hoteladmin データベースを作成します。

以下の内容を作成します。

テーブル
外部キー
制約
インデックス
002_CreateStoredProcedures.sql

ダッシュボードなどで使用するストアドプロシージャを作成します。

001_DevelopmentData.sql

開発環境で使用する基本データを登録します。

主な内容：

客室タイプ
客室データ
002_SalesReportDemoData.sql

必要に応じて実行する開発・デモ用データです。

売上レポートやグラフ確認用として、架空の日本人ゲストと過去の予約データを登録します。

登録される顧客名や予約情報はすべて架空データです。

実在する顧客データは含まれていません。

データベースのセットアップ

SQL Server Management Studio（SSMS）を起動し、ローカル SQL Server に接続します。

SQL Server LocalDB を使用する場合：

(localdb)\MSSQLLocalDB

認証方法：

Windows 認証

その後、以下の SQL ファイルを順番に実行してください。

Database/Migrations/001_InitialSchema.sql
Database/Migrations/002_CreateStoredProcedures.sql
Database/Seeds/001_DevelopmentData.sql
Database/Seeds/002_SalesReportDemoData.sql ※任意

最初のスクリプトで hoteladmin データベースが作成されます。

接続文字列

Web.config の HotelDB 接続文字列が、使用するローカルデータベースを参照していることを確認してください。

SQL Server LocalDB を使用する場合：

<connectionStrings>
  <add name="HotelDB"
       connectionString="Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=hoteladmin;Integrated Security=True;MultipleActiveResultSets=True"
       providerName="System.Data.SqlClient" />
</connectionStrings>

SQL Server Express を使用する場合は、環境に合わせて Data Source を変更してください。

例：

Data Source=.\SQLEXPRESS;
プロジェクトの起動方法

データベースのセットアップが完了したら、以下の手順で起動します。

Visual Studio で hotel.sln を開く
Web.config の HotelDB 接続文字列を確認する
ソリューションをビルドする
Visual Studio / IIS Express からプロジェクトを起動する
Login.aspx を開く
開発・動作確認用の管理者アカウントでログインする
売上レポート用デモデータ

002_SalesReportDemoData.sql は開発・デモ表示専用のデータです。

このファイルを実行すると、以下の確認ができます。

月次売上グラフ
月次予約件数
年間売上集計
前年比
過去年度の売上データ

本番環境用のデータではありません。

Gitへコミットしないファイル

ローカル SQL Server のデータベースファイルやバックアップファイルは Git にコミットしないでください。

.gitignore の例：

.vs/
bin/
obj/
packages/

*.user
*.csproj.user

*.mdf
*.ldf
*.bak
*.pdb

一方、SQL マイグレーションファイルやシードファイルは Git 管理対象です。

*.sql
新しい開発者向け簡単セットアップ
リポジトリを clone
SSMS を起動
(localdb)\MSSQLLocalDB に接続
001_InitialSchema.sql を実行
002_CreateStoredProcedures.sql を実行
001_DevelopmentData.sql を実行
必要に応じて 002_SalesReportDemoData.sql を実行
Visual Studio で hotel.sln を開く
Web.config の接続文字列を確認
ソリューションをビルド
プロジェクトを起動
Login.aspx からログイン
開発用データについて

開発・動作確認用として以下のサンプルデータを使用できます。

ゲスト情報
客室情報
客室タイプ
予約履歴
売上レポート確認用データ

これらは開発および画面確認を目的としたデータです。

補足

環境によって SQL Server のインスタンス名が異なる場合があります。

その場合は Web.config の Data Source を、自分の SQL Server 環境に合わせて変更してください。

プロジェクトの目的

本プロジェクトは、ホテル管理業務をひとつの管理画面にまとめることを目的としています。

特に以下を重視しています。

必要な情報を素早く確認できること
管理画面として見やすいUIであること
機能ごとにページを整理すること
データベースとの連携を分かりやすくすること
今後の機能追加や保守をしやすい構成にすること
