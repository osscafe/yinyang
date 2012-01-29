<?php
class hSQLParser {
	var $reserved = array();
	var $functions = array();
	function __construct($sql = false) {
		if ($sql) $this->parse($sql);
	}

	function parse($sql) {
		$valid = preg_match('/^'.
			'(?P<select>SELECT\s+.+?)'.
			'(?P<from>\s+FROM\s+.+?)'.
			'(?P<where>\s+WHERE\s+.+?)?'.
			'(?P<order>\s+ORDER BY\s+.+?)?'.
			'(?P<limit>\s+LIMIT\s+.+?)?'.
		'$/', $sql, $matches);
		var_dump($matches); die;
	
	
		$valid = preg_match('/^'.
			'(?P<select>SELECT(\s+\*|((\s+|,\s+)[a-z0-9#\.])(\s+AS\s+[a-z][a-z0-9_]*)?)+)'.
			'(?P<from>\s+FROM\s+([\.\/a-zA-Z0-9_\-\*]+))'.
			'(?P<where>\s+WHERE((\s+|AND\s+)([a-z]+)\s+(HAS|IS|IS NOT|=|<>|<|>|<=|>=)\s+([1-9][0-9]*|\'.*?\'))+)?'.
			'(?P<order>\s+ORDER BY((\s+|,\s+)([a-z][a-z0-9_]*)))?'.
			'(?P<limit>\s+LIMIT\s+([1-9][0-9]*))?'.
		'$/', $sql, $matches);
		
		if (!$valid)
			return false;
		
		var_dump($matches); die;
	}

}

$q = $_GET['q'];
$parser = new hSQLParser($q);


//ダミー出力
$data = array(
	array(
		'title' => 'ミルクコーヒーの歴史(1)',
		'description' => '開発の動機から、その実現に至るまでを概説します。',
		'file' => 'history1.html',
		'created' => '2012-01-28T21:18+09:00',
		'modified' => '2012-01-28T21:18+09:18',
	),
	array(
		'title' => 'ミルクコーヒーの歴史(2)',
		'description' => '開発の動機から、その実現に至るまでを概説します。',
		'file' => 'history2.html',
		'created' => '2012-01-28T21:18+09:00',
		'modified' => '2012-01-28T21:18+09:18',
	),
	array(
		'title' => 'ミルクコーヒーの歴史(3)',
		'description' => $_GET['q'],
		'file' => 'history3.html',
		'created' => '2012-01-28T21:18+09:00',
		'modified' => '2012-01-28T21:18+09:18',
	)
);

echo json_encode($data);