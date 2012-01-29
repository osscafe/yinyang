<?php
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
		'description' => '開発の動機から、その実現に至るまでを概説します。',
		'file' => 'history3.html',
		'created' => '2012-01-28T21:18+09:00',
		'modified' => '2012-01-28T21:18+09:18',
	)
);

echo json_encode($data);