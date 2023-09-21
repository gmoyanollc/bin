// cat << 'EOF' | php
<?php 
  echo 'begin...';
  ini_set( 'display_errors', 1 );
  error_reporting( E_ALL );
  $headers = Array(
    'From:' => 'noreply@rvfinancing.com'
  );
  mail('g@blurry.world', 'the subject', 'the body', $headers);
  echo 'done.';  
?>

