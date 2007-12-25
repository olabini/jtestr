value1 :abc, :cde
$__was_in_config = 42

junit "unit" => ['org.jtestr.test.JUnit3Test', 'org.jtestr.test.JUnit4Test']
junit ['org.jtestr.test.JUnit3Test']
junit 'org.jtestr.test.JUnit4Test'
