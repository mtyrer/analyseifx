<?php
use Restserver\Libraries\REST_Controller;
defined('BASEPATH') OR exit('No direct script access allowed');

// This can be removed if you use __autoload() in config.php OR use Modular Extensions
/** @noinspection PhpIncludeInspection */
//To Solve File REST_Controller not found
require APPPATH . 'libraries/REST_Controller.php';
require APPPATH . 'libraries/Format.php';

/**
 * This is an example of a few basic user interaction methods you could use
 * all done with a hardcoded array
 *
 * @package         CodeIgniter
 * @subpackage      Rest Server
 * @category        Controller
 * @author          Phil Sturgeon, Chris Kacerguis
 * @license         MIT
 * @link            https://github.com/chriskacerguis/codeigniter-restserver
 */
class Instance extends REST_Controller {

    function __construct()
    {
        // Construct the parent class
        parent::__construct();

        // Configure limits on our controller methods
        // Ensure you have created the 'limits' table and enabled 'limits' within application/config/rest.php
        $this->methods['instances_get']['limit'] = 500; // 500 requests per hour per user/key
        $this->methods['instance_post']['limit'] = 100; // 100 requests per hour per user/key
        $this->methods['instance_delete']['limit'] = 50; // 50 requests per hour per user/key
        //$this->load->model('analysedb');

    }

    public function instances_get()
    {
        $host=$this->get('host');
        $client=$this->get('client');

        // Users from a data store e.g. database
        $instances = $this->analysedb->instances_get($host, $client);
        if ($instances)
        {
            // Set the response and exit
            $this->response($instances, REST_Controller::HTTP_OK); // OK (200) being the HTTP response code
        }
        else
        {
            // Set the response and exit
            $this->response([
                'status' => FALSE,
                'message' => 'No users were found'
            ], REST_Controller::HTTP_NOT_FOUND); // NOT_FOUND (404) being the HTTP response code
        }
    }

    public function instance_delete($instance_id) {
       
        $result = $this->analysedb->instance_delete($instance_id);

        if ($result) {

            $message = [
                'instance_id' => $instance_id,
                'message' => 'Deleted the instance'
            ];
    
            $this->set_response($message, REST_Controller::HTTP_OK); // NO_CONTENT (204) being the HTTP response code
        } else {
            $this->response("Failed to delete data for the instance $instance_id", REST_Controller::HTTP_BAD_REQUEST); // BAD_REQUEST (400) being the HTTP response code
        }
    }

    public function instance_exists_name_get($client, $host, $instance) {

        if ($this->analysedb->instance_exists_name($client, $host, $instance)) {
            $retval = ['instace_exits' => 'exist'];
        } else {
            $retval = ['instace_exits' => 'not exist'];
        }
        $this->set_response($retval, REST_Controller::HTTP_OK);
    }

    public function instance_post() {
       
        #phpinfo();
        $action = $this->post("action");
        
        $name = $this->post("name");
        
        $result = FALSE;

        if ($action == "update") {
            $id = $this->post("id");
            $result = $this->analysedb->instance_update_name($id, $name);
            $message = [
                'instance_name' => $name,
                'message' => 'updated the instance'
            ];
        }

        if ($action == "add") {
            $host=$this->post("host");
            $client=$this->post("client");
            
            $resultarr = $this->analysedb->instance_add($name, $host, $client);
            $result = $resultarr[0];
            $insertid = $resultarr[1];

            $message = [
                'instance_id' => $insertid,
                'message' => 'Updated the instance'
            ];
        } 
    
    
        //$result = $this->analysedb->instance_delete($instance_id);
        
        if ($result === TRUE) {
            $this->set_response($message, REST_Controller::HTTP_OK); // NO_CONTENT (204) being the HTTP response code
        } else {
            $message = [
                'text' => 'Sad. Something bad happened',
                'action' => $action,
                'instance_name' => $name 
            ];
            $this->response($message, REST_Controller::HTTP_BAD_REQUEST); // BAD_REQUEST (400) being the HTTP response code
        }
    }
}
