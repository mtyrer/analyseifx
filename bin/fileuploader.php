<?php
//phpinfo();
// fileuploader.php
// 'images' refers to your file input name attribute
if (empty($_FILES['statfiles'])) {
    echo json_encode(['error'=>'No files found for upload.']); 
    // or you can throw an exception 
    return; // terminate
}

// get the files posted
$files = $_FILES['statfiles'];

// a flag to see if everything is ok
$success = null;

// file paths to store
$paths= [];

// get file names
$filenames = $files['name'];
//phpinfo();
// loop and process files
$basename=dirname($_SERVER['SCRIPT_FILENAME'],2);
for($i=0; $i < count($filenames); $i++){
    $name=$_POST['client'] . "_" . $_POST['host'] . "_" . $_POST['instance'] . "_";
    $ext = explode('.', basename($filenames[$i]));
    $target = $basename . DIRECTORY_SEPARATOR . "uploads" . DIRECTORY_SEPARATOR . $name. md5(uniqid()) . "." . array_pop($ext);
    if(move_uploaded_file($files['tmp_name'][$i], $target)) {
        $success = true;
        $paths[] = $target;
        $cmd = "python " . dirname($_SERVER['SCRIPT_FILENAME'],1) . "/load_metric.py -c " . $_POST['client'] . " -s " . $_POST['host'] . " -i " . $_POST['instance'] . " -f " . $target;
        echo ($cmd);
        exec($cmd);
    } else {
        $success = false;
        break;
    }
}

// check and process based on successful status 
if ($success === true) {
    // call the function to save all data to database
    // code for the following function `save_data` is not 
    // mentioned in this example
    //save_data($paths);

    // store a successful response (default at least an empty array). You
    // could return any additional response info you need to the plugin for
    // advanced implementations.
    $output = [];
    // for example you can get the list of files uploaded this way
    // $output = ['uploaded' => $paths];
} elseif ($success === false) {
    $output = ['error'=>'Error while uploading images. Contact the system administrator'];
    // delete any uploaded files
    foreach ($paths as $file) {
        unlink($file);
    }
} else {
    $output = ['error'=>'No files were processed.'];
}

// return a json encoded response for plugin to process successfully
echo json_encode($output);

?>