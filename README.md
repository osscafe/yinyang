# milk.coffee

milk.coffeeはCoffeeScriptで書かれた、クライアントサイドテンプレートエンジンです。

※milkは現在、鋭意実装作業中です。まだほとんど使えませんので悪しからず :-)

## はじめに

milkの目標と特徴は、

1. コンテンツとレイアウトの分離
2. 純粋なHTML
3. クライアントサイド主体
4. プログレッシブエンハンスメントの実現

という点にあります。1については、どのテンプレートエンジンでも実現していると思われるでしょうか? また、CSSで解決するべきものだと思われるでしょうか? しかし、実際のHTMLでは、多くの場合レイアウトをHTMLタグとして表現してしまっています。その結果、コンテンツがレイアウト内に点在する事になり、メンテナンス性が著しく下がる結果となっているのです。

ここで、milkが採用する方策は、HTMLをコンテンツ部分とレイアウト部分の2つのHTMLに分離することです。ここでは、便宜的に

* コンテンツ部分のHTML → ドキュメント
* レイアウト部分のHTML → テンプレート

と呼ぶ事にします。

(かつてのXSLTは、milkに近い思想を持っていましたが、複雑すぎるという決定的な欠点を持っていました)

### milkを実現する技術

milkに特徴的なものをいくつか列挙します。

* **HTMLテンプレート** : モックアップページがそのままテンプレートに。 
* **遅延レンダリング** : レンダリング開始時には未取得のデータ(AjaxやhSQL)を、非同期で描画する仕組み。
* **hSQL** : サーバ上のHTMLファイル群をデータベースに見立て、ページ情報を取得する仕組み

----

## フレームワーク

milkを使う典型例は、下記のようなファイル構成になります。

* DOCUMENT_ROOT
	* index.html
	* about.html
	* contact.html
	* style
		* template.html
		* style.css
	* js
		* milk.js
		* jquery-1.7.1.min.js

index.html、about.html、contact.html は、一切のレイアウト情報を持たない素のドキュメントです。それに対し、style/template.html はレイアウト情報を含むHTMLです。

index.html(など)のHTMLで、HEADタグには、

	<link rel="template" href="style/template.html">
	<script src="js/milk.js"></script>

の2行が必要です。LINKタグで、テンプレートになるHTMLファイルを指定している点に注意して下さい(CSSではなく)。また、現バージョンではjQueryに依存しているため、jQueryも必要です。

また、後述のhSQLを利用するには、サーバサイドのヘルパーを導入します。上記のファイル群に加えて、下記のファイルをドキュメントルートに加える必要があります。詳しくは、hSQLの項を参照。hSQLは、テンプレートからサーバ上のファイルツリーとHTMLの情報にアクセスするための便利な方法です。

* hsql.php
* .htaccess

----

## テンプレート

多くのテンプレートエンジンと異なり、milkのテンプレートはHTML完全互換です。全てのテンプレートタグはHTMLコメント内に記述されます。

### テンプレート変数

最も単純な形式です。<!--{変数名}--> の形で使われ、<!--{end}--> まではダミーテキストとして無視されます。(テンプレートエンジンで解釈されません)

	<!--{copyright}-->&copy; 2012 Copyright reserved.<!--{end}-->

また、

	<a href="#{link.url}">LINK</a>

のような記法も許されています。HTMLタグの内側に書く場合は、こちらの方が望ましいでしょう。

※テンプレート変数を使うには、JavaScriptで変数をセットする必要があります。

### メタデータ変数

テンプレート変数と使い方は同じですが、元になるドキュメントで指定されたMETAタグの内容を参照します。

	<!--{meta.description}-->Some clever comment about the company<!--{end}-->

あるいは、

	<meta name="author" content="#{meta.author}">

のように使います。


### ドキュメント変数

ドキュメント変数は、CSSセレクタによって内容を取得します。

	<!--{@title}-->Site Title<!--{end}-->

この場合、jQueryで言うところの、$('title').text() に置き換えられます。

### ループ変数

VALUE in ARRAY の形式で、ループを作成できます。ループはネスト可能です。ループ内で変数を参照するにはドット「.」で繋いで、VALUE.PROPERTY のようにします。もしテンプレート変数に存在する名前を使用した場合は、ループ変数が優先です。

	<nav>
		<!--{link in links}-->
		<a href="#{link.url}"><!--{link.title}-->Home<!--{end}--></a>
		<!--{more}-->
		<a href="#">About</a>
		<a href="#">Contact</a>
		<!--{end}-->
	</nav>

milkが特徴的なのは、このループの中で{more}から{end}までダミーテキストの入力を許可している点です。これにより、デザイナは繰返しがある部分も、実際に近い状況でテンプレートデザインすることが可能になります。

### 変数フィルタ

主に、日付・通貨などの整形用のフィルタが用意されています。

	<!--{post.date|date:Y/m/d}-->Home<!--{end}-->

のように、フィルタをパイプ「|」でつなぎ、コロン「:」の後に指定内容を書きます。

* date : 日付の整形
* number : 数値の整形

### テンプレートのプリコンパイル (検討中)

現在のバージョンではテンプレートは、都度都度クライアントサイドで解析・実行されます。milkではダミーテキストをテンプレート内に残す事ができるため、ファイルサイズが大きくなりがちです。この問題を解決するには、変換済みのテンプレートをJSON形式でサーバサイドに保存する必要があります。ですが、なるべくクライアントサイドで完結することを当面目指すため、今のところは実装されていません。

## Ajax

milk.coffeeでは、テンプレート変数に直接Ajax通信の結果をセット可能です。指定したパスには、JSON形式のファイルを置くか、JSON形式を返すスクリプトを配置しておきます。例えば、

	<meta name="milk:ajax.links" content="data/links.json">

のようにMETAタグを設定します。すると、テンプレートからは、ajax.links変数を参照すれば、問合せ結果にアクセスできるようになります。

----

## hSQL

hSQL(html Search Query Language)を使うと、テンプレートからhSQLを通じてサーバ上のファイルツリーとページ情報にアクセスできます。hSQLは、SQLに似た文法を持つ、HTMLファイルの検索クエリ言語です。例えば、

	<meta name="milk:hsql.posts" content="SELECT * FROM ./  LIMIT 3">

のように、特殊なMETAタグを埋め込むと、テンプレートからhsql.posts変数にアクセスできるようになります。この場合、カレントフォルダ内のページから、3つのページ(HTML)のデータを(新しい順で)取得します。hSQLの問合せ結果は、次のようなJSON形式になっており、そのまま変数にセットされます。

	[
		{
			title : 'ミルクコーヒーの歴史',
			description : '開発の動機から、その実現に至るまでを概説します。',
			file : 'history.html',
			created : '2012-01-28T21:18+09:00',
			created : '2012-01-28T21:18+09:18'
		},
		{
			title : 'ミルクコーヒーの淹れ方',
			…省略
		},
		…省略
	]


なお、hSQLを使うには、サーバサイドにヘルパーファイルが必要です。現在のところPHPに対応したファイルが提供されています。下記の2つのファイルをドキュメントルートに配置します。

* hsql.php
* .htaccess

### hSQLの文法

#### SELECT節

SQLではデータベースのカラムをSELECT節で指定するのが一般的ですが、hSQLでは、ファイル情報・HTMLのメタ情報・ HTMLタグ が、その対象です。

* ファイル情報
	* file.name
	* file.created
	* file.modified
* HTMLのメタ情報
	* meta.description
	* meta.author
* HTMLタグ (CSSセレクタでアクセス)
	* @title → TITLEタグの中身

など。

なお、ワイルドカード「*」が許されていますが、SQLと違い、これはよく使う表現へのショートハンドとなっています。

	SELECT * FROM ./ LIMIT 3

と書いた場合、

	SELECT
		@title as title,
		meta.description as description,
		file.name as file,
		file.created as created,
		file.modified as modified
	FROM
		./
	LIMIT
		3

としてhSQLが実行されます。

#### WHERE節

WHERE節は省略可能です。

例えば、METAキーワードとして「hot」が指定されているものに限定する場合、

	WHERE meta.keyword HAS 'hot'

と指定すればOKです。HASは文字列を含む場合に真となる演算子です。

WHERE節で使える演算子には、次のものがあります。

* 等号 : =, IS
* 不等号 : &lt;&gt;, IS NOT
* 不等号 : &lt;, &gt;, &lt;=, &gt;=
* 含有 : HAS


#### ORDER BY節

ORDER BY節は省略可能です。省略した場合は、

	ORDER BY file.created DESC

が指定されたものとみなします。

#### LIMIT節

LIMIT節は省略可能です。省略した場合は、

	LIMIT 10

が指定されたものとみなします。

	SELECT
		@title as title,
		meta.description as description,
		file.name as file,
		file.created as created,
		file.modified as modified
	FROM
		./
	WHERE
		'hot' IN meta.keyword
	ORDER BY
		file.created DESC
	LIMIT
		3