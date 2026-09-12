Hotel Admin Dashboard - データベースセットアップ

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

各ファイルの役割

001_InitialSchema.sql

hoteladmin データベースを作成します。

テーブル、外部キー、制約、インデックスを作成します。

002_CreateStoredProcedures.sql

ダッシュボードで使用するストアドプロシージャを作成します。

001_DevelopmentData.sql

客室タイプと開発用の客室データを登録します。

002_SalesReportDemoData.sql

任意で実行します。

売上レポートやグラフ確認用の架空の日本人ゲストと過去の予約データを登録します。

データベースのセットアップ

SQL Server Management Studio（SSMS）を起動し、ローカルの SQL Server に接続します。

SQL Server LocalDB を使用する場合は、以下を指定してください。

(localdb)\MSSQLLocalDB

認証方法は Windows 認証を使用します。

その後、以下の SQL ファイルを順番に実行してください。

1. Database/Migrations/001_InitialSchema.sql
2. Database/Migrations/002_CreateStoredProcedures.sql
3. Database/Seeds/001_DevelopmentData.sql
4. Database/Seeds/002_SalesReportDemoData.sql   ※任意

最初のスクリプトで hoteladmin データベースが自動的に作成されます。

接続文字列

Web.config の HotelDB 接続文字列が、使用するローカルデータベースを参照していることを確認してください。

SQL Server LocalDB を使用する場合の例:

<connectionStrings>
  <add name="HotelDB"
       connectionString="Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=hoteladmin;Integrated Security=True;MultipleActiveResultSets=True"
       providerName="System.Data.SqlClient" />
</connectionStrings>

SQL Server Express を使用する場合は、Data Source を環境に合わせて変更してください。

例:

Data Source=.\SQLEXPRESS;

プロジェクトの起動方法

データベースのセットアップが完了したら、以下の手順で起動します。

Visual Studio で hotel.sln を開きます。

Web.config の HotelDB 接続文字列を確認します。

ソリューションをビルドします。

Visual Studio / IIS Express からプロジェクトを起動します。

ブラウザでダッシュボードを確認します。

売上レポート用デモデータ

002_SalesReportDemoData.sql は、開発・デモ表示専用のデータです。

このファイルを実行すると、以下の確認ができます。

月次売上グラフ

月次ゲスト数グラフ

年間売上集計

前年比

過去年度の売上データ

登録される顧客名や予約情報はすべて架空データです。

実在する顧客データは含まれていません。

Git へコミットしないファイル

ローカル SQL Server のデータベースファイルやバックアップファイルはコミットしないでください。

.gitignore の例:

*.mdf
*.ldf
*.bak

一方、SQL マイグレーション・シードファイルは Git 管理対象にしてください。

*.sql

新しい開発者向けの簡単セットアップ

1. リポジトリを clone
2. SSMS を起動
3. (localdb)\MSSQLLocalDB に接続
4. 001_InitialSchema.sql を実行
5. 002_CreateStoredProcedures.sql を実行
6. 001_DevelopmentData.sql を実行
7. 売上レポート用デモデータが必要な場合は 002_SalesReportDemoData.sql を実行
8. Visual Studio で hotel.sln を開く
9. Web.config の接続文字列を確認
10. プロジェクトを起動

補足

環境によって SQL Server のインスタンス名が異なる場合があります。

その場合は Web.config の Data Source を、自分の SQL Server 環境に合わせて変更してください。