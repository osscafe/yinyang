<?php
# The MIT License
# Copyright © 2012, CogniTom Academic Design & Tsutomu Kawamura.
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of 
# this software and associated documentation files (the “Software”), to deal in 
# the Software without restriction, including without limitation the rights to use, 
# copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the 
# Software, and to permit persons to whom the Software is furnished to do so, 
# subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all 
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS 
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR 
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER 
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN 
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

$q = isset($_REQUEST['q']) ? $_REQUEST['q'] : '';

$parser = new hSQLParser($q);
$result = $parser->fetch();
echo json_encode($result);



// --- CogniTom Academic Design - (c) Copyright Tsutomu Kawamura <kawamura@cognitom.com> MIT Licensed

define('HSQL_VERSION', '0.1.0');

/**
 * hSQLParser.
 *
 * Search HTML files by SQL like language.
 */
class hSQLParser {
	var $site_dir;
	var $cd;
	var $select;
	var $from;
	var $where;
	var $order;
	var $offset;
	var $limit;
	
	/**
	 * コンストラクタ
	 */
	public function __construct($q = false, $cd = './') {
		//初期値
		$this->site_dir = dirname(__FILE__);
		$this->cd = '/';
		$this->select = array();
		$this->from = $this->site_dir;
		$this->where = array();
		$this->order = array();
		$this->offset = 0;
		$this->limit = 10;
		
		//カレントディレクトリの特定
		$cd = preg_replace('/\/+/', '/', $cd);//スラッシュのダブりを除去
		$cd = (
			!preg_match('/^[\.\/a-zA-Z0-9_\-]+$/', $cd) ||
			preg_match('/^\.\.\//', $cd)
		) ? '' : preg_replace('/^\.\//', '', $cd);//「./」を左端から除去
		$cd = '/'.$cd;
		if (preg_match('/[^\/]$/', $cd))
			$cd = $cd.'/';
		$this->cd = $cd;
		
		//パース
		if ($q) $this->parse($q);
	}
	
	/**
	 * パース
	 */
	public function parse($q) {
		$valid = preg_match('/^'.
			'(?P<select>SELECT\s+.+?)'.
			'(?P<from>\s+FROM\s+.+?)'.
			'(?P<where>\s+WHERE\s+.+?)?'.
			'(?P<order>\s+ORDER BY\s+.+?)?'.
			'(?P<limit>\s+LIMIT\s+.+?)?'.
		'$/', $q, $matches);
		
		return ($valid &&
			$this->parseSelect(trim($matches['select'])) &&
			$this->parseFrom(trim($matches['from'])) &&
			$this->parseWhere(trim($matches['where'])) &&
			$this->parseOrder(trim($matches['order'])) &&
			$this->parseLimit(trim($matches['limit']))
		);
	}
	
	/**
	 * ファイル情報の取得
	 */
	public function fetch(){
		$files = array();
		foreach (glob($this->from.'*.html') as $filename) {
			$f = $this->getFileStat($filename);
			$m = $this->getFileMetaAndContent($filename);
			$files[] = array_merge($f, $m);
		}
		$files = $this->where($files);
		$files = $this->order($files);
		$files = $this->limit($files);
		return $this->select($files);
	}
	
	/**
	 * レコードのフィルタ
	 */
	private function where($files){
		//TODO: WHERE条件で、フィルタリング
		return $files;
	}
	
	/**
	 * レコードのソート
	 */
	private function order($files){
		//TODO: ソート
		return $files;
	}
	
	/**
	 * レコードの件数制限
	 */
	private function limit($files){
		$arr = array();
		for ($i = $this->offset; isset($files[$i]) && $i < $this->offset + $this->limit; $i++){
			$arr[] = $files[$i];
		}
		return $arr;
	}
	
	/**
	 * レコードの選択
	 */
	private function select($files){
		$arr = array();
		foreach ($files as $file){
			$f = array();
			foreach ($this->select as $key => $value) {
				$f[$key] = isset($file[$value]) ? $file[$value] : '';
			}
			$arr[] = $f;
		}
		return $arr;
	}
	
	/**
	 * ファイル情報を配列で返す
	 */
	private function getFileStat($filename){
		$s = stat($filename);
		return array(
			'file.name' => basename($filename),
			'file.created' => $s['ctime'],
			'file.modified' => $s['mtime'],
			'file.size' => $s['size'],
		);
	}
	
	/**
	 * メタ情報とセレクタで設定された内容を配列として返す
	 */
	private function getFileMetaAndContent($filename, $selectors=null){
		$html = file_get_contents($filename);//ファイルパスからHTMLを取得
		$html = mb_convert_encoding($html, "HTML-ENTITIES", "auto");//文字化け回避
		if (!$selectors){
			$selectors = array(
				'@title',
			);
		}
		return array_merge(
			$this->getFileMeta($html),
			$this->getFileContent($html, $selectors)
		);
	}
	
	/**
	 * メタ情報を抜き出して配列で返す
	 */
	private function getFileMeta($html){
		$arr = array();
		$dom = new SelectorDOM($html);
		$metas = $dom->select('meta');
		foreach ($metas as $meta){
			if (isset($meta['attributes']['name'])){
				$name = $meta['attributes']['name'];
				$content = $meta['attributes']['content'];
				$arr['meta.'.$name] = $content;
			}
		}
		return $arr;
	}
	
	/**
	 * 指定されたセレクタの内容を配列で返す
	 */
	private function getFileContent($html, $selectors){
		$arr = array();
		$dom = new SelectorDOM($html);
		foreach ($selectors as $selector){
			$t = $dom->select(str_replace('@', '', $selector));
			$arr[$selector] = sizeof($t) ? $t[0]['text'] : '';
		}
		return $arr;
	}
	
	/**
	 * SELECT節のパース
	 */
	private function parseSelect($raw){
		$columns = array();
		foreach (explode(',', preg_replace('/^SELECT\s+/', '', $raw)) as $column){
			$column = trim($column);
			if ($column == '*'){
				$columns['title'] = '@title';
				$columns['description'] = 'meta.description';
				$columns['file'] = 'file.name';
				$columns['created'] = 'file.created';
				$columns['modified'] = 'file.modified';
			} elseif (preg_match('/^(.+?)\s+AS\s+(.*)$/', $column, $matches)) {
				$alias = $matches[2];
				$alias = preg_replace('/^[^a-z]+/', '', $alias);
				$alias = preg_replace('/[^a-z0-9_]/', '_', $alias);
				$columns[$alias] = $matches[1];
			} elseif (preg_match('/^(?:file|meta)\.([a-z][a-z0-9]*)$/', $column, $matches)) {
				$columns[$matches[1]] = $matches[0];
			} else {
				$alias = $column;
				$alias = preg_replace('/^[^a-z]+/', '', $alias);
				$alias = preg_replace('/[^a-z0-9_]/', '_', $alias);
				$columns[$alias] = $column;
			}
		}
		$this->select = $columns;
		return true;
	}
	
	/**
	 * FROM節のパース (今のところJOINなし)
	 */
	private function parseFrom($raw){
		$from = preg_replace('/^FROM\s+/', '', $raw);
		$from = preg_replace('/\/+/', '/', $from);//スラッシュのダブりを除去
		if (!preg_match('/^[\.\/a-zA-Z0-9_\-]+$/', $from)) $from = './';//不正な文字を含む場合はデフォルトに
		if ($from[strlen($from)-1] != '/') $from .= '/';//終端のスラッシュが無い場合は、追加
		
		if (preg_match('/^\//', $from)){
			$this->from = $this->site_dir.$from;
		} else {
			$from = preg_replace('/^\.\//', '', $from);//「./」を左端から除去
			$cd = $this->cd;
			$upcount = 0;
			if (preg_match('/^(\.\.\/)+/', $cd, $matches)){
				for ($i = 0; $i < substr_count($matches[0], '../'); $i++)
					$cd = preg_replace('/[^\/]+\/$/', '', $from);
			}
			$this->from = $this->site_dir.$cd.$from;
		}
		return true;
	}
	
	/**
	 * WHERE節のパース (今のところANDのみ)
	 */
	private function parseWhere($raw){
		$wheres = array();
		foreach (explode('AND', preg_replace('/^WHERE\s+/', '', $raw)) as $where){
			$where = trim($where);
			if (preg_match('/^([a-z][a-z0-9]*)\s+(=|<>|<|>|<=|>=|IS|IS NOT|HAS)\s+(.*)$/', $where, $matches)){
				$wheres[] = array('op'=>$matches[2], 'lh'=>$matches[1], 'rh'=>$matches[3]);
			}
		}
		$this->where = $wheres;
		return true;
	}
	
	/**
	 * ORDER節のパース
	 */
	private function parseOrder($raw){
		$orders = array();
		foreach (explode(',', preg_replace('/^ORDER BY\s+/', '', $raw)) as $order){
			$order = trim($order);
			if (preg_match('/^([a-z][a-z0-9]*)(?:\s+(DESC|ASC))?$/', $order, $matches)){
				$orders[$matches[1]] = isset($matches[2]) && $matches[2] == 'DESC' ? 'DESC' : 'ASC';
			}
		}
		$this->order = $orders;
		return true;
	}
	
	/**
	 * LIMIT節のパース
	 */
	private function parseLimit($raw){
		$limit = preg_replace('/^LIMIT\s+/', '', $raw);
		if (preg_match('/^[1-9][0-9]*$/', $limit)){
			$this->offset = 0;
			$this->limit = $limit-0;
		} elseif (preg_match('/^([1-9][0-9]*),\s*([1-9][0-9]*)$/', $limit, $matches)){
			$this->offset = $matches[1]-0;
			$this->limit = $matches[2]-0;
		}
		return true;
	}
}

?><?php

// --- Selector.inc - (c) Copyright TJ Holowaychuk <tj@vision-media.ca> MIT Licensed

define('SELECTOR_VERSION', '1.1.3');

/**
 * SelectorDOM.
 *
 * Persitant object for selecting elements.
 *
 *   $dom = new SelectorDOM($html);
 *   $links = $dom->select('a');
 *   $list_links = $dom->select('ul li a');
 *
 */

class SelectorDOM {
  public function SelectorDOM($html) {
    $this->html = $html;
    $this->dom = new DOMDocument();
    @$this->dom->loadHTML($html);
    $this->xpath = new DOMXpath($this->dom);
  }
  
  public function select($selector, $as_array = true) {
    $elements = $this->xpath->evaluate(selector_to_xpath($selector));
    return $as_array ? elements_to_array($elements) : $element;
  }
}

/**
 * Select elements from $html using the css $selector.
 * When $as_array is true elements and their children will
 * be converted to array's containing the following keys (defaults to true):
 *
 *  - name : element name
 *  - text : element text
 *  - children : array of children elements
 *  - attributes : attributes array
 *
 * Otherwise regular DOMElement's will be returned.
 */

function select_elements($selector, $html, $as_array = true) {
  $dom = new SelectorDOM($html);
  return $dom->select($selector, $as_array);
}

/**
 * Convert $elements to an array.
 */

function elements_to_array($elements) {
  $array = array();
  for ($i = 0, $length = $elements->length; $i < $length; ++$i)
    if ($elements->item($i)->nodeType == XML_ELEMENT_NODE)
      array_push($array, element_to_array($elements->item($i)));
  return $array;
}

/**
 * Convert $element to an array.
 */

function element_to_array($element) {
  $array = array(
    'name' => $element->nodeName,
    'attributes' => array(),
    'text' => $element->textContent,
    'children' =>elements_to_array($element->childNodes)
    );
  if ($element->attributes->length)
    foreach($element->attributes as $key => $attr)
      $array['attributes'][$key] = $attr->value;
  return $array;
}

/**
 * Convert $selector into an XPath string.
 */

function selector_to_xpath($selector) {
  $selector = 'descendant-or-self::' . $selector;
  // ,
  $selector = preg_replace('/\s*,\s*/', '|descendant-or-self::', $selector);
  // :button, :submit, etc
  $selector = preg_replace('/:(button|submit|file|checkbox|radio|image|reset|text|password)/', 'input[@type="\1"]', $selector);
  // [id]
  $selector = preg_replace('/\[(\w+)\]/', '*[@\1]', $selector);
  // foo[id=foo]
  $selector = preg_replace('/\[(\w+)=[\'"]?(.*?)[\'"]?\]/', '[@\1="\2"]', $selector);
  // [id=foo]
  $selector = str_replace(':[', ':*[', $selector);
  // div#foo
  $selector = preg_replace('/([\w\-]+)\#([\w\-]+)/', '\1[@id="\2"]', $selector);
  // #foo
  $selector = preg_replace('/\#([\w\-]+)/', '*[@id="\1"]', $selector);
  // div.foo
  $selector = preg_replace('/([\w\-]+)\.([\w\-]+)/', '\1[contains(@class,"\2")]', $selector);
  // .foo
  $selector = preg_replace('/\.([\w\-]+)/', '*[contains(@class,"\1")]', $selector);
  // div:first-child
  $selector = preg_replace('/([\w\-]+):first-child/', '*/\1[position()=1]', $selector);
  // div:last-child
  $selector = preg_replace('/([\w\-]+):last-child/', '*/\1[position()=last()]', $selector);
  // :first-child
  $selector = str_replace(':first-child', '*/*[position()=1]', $selector);
  // :last-child
  $selector = str_replace(':last-child', '*/*[position()=last()]', $selector);
  // div:nth-child
  $selector = preg_replace('/([\w\-]+):nth-child\((\d+)\)/', '*/\1[position()=\2]', $selector);
  // :nth-child
  $selector = preg_replace('/:nth-child\((\d+)\)/', '*/*[position()=\1]', $selector);
  // :contains(Foo)
  $selector = preg_replace('/([\w\-]+):contains\((.*?)\)/', '\1[contains(string(.),"\2")]', $selector);
  // >
  $selector = preg_replace('/\s*>\s*/', '/', $selector);
  // ~
  $selector = preg_replace('/\s*~\s*/', '/following-sibling::', $selector);
  // + 
  $selector = preg_replace('/\s*\+\s*([\w\-]+)/', '/following-sibling::\1[position()=1]', $selector);
  // ' '
  $selector = preg_replace('/\s+/', '/descendant::', $selector);
  $selector = str_replace(']*', ']', $selector);
  $selector = str_replace(']/*', ']', $selector);
  return $selector;
}