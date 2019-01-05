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
class Host extends REST_Controller {

    function __construct()
    {
        // Construct the parent class
        parent::__construct();

        // Configure limits on our controller methods
        // Ensure you have created the 'limits' table and enabled 'limits' within application/config/rest.php
        $this->methods['hosts_get']['limit'] = 500; // 500 requests per hour per user/key
        //$this->methods['users_post']['limit'] = 100; // 100 requests per hour per user/key
        //$this->methods['users_delete']['limit'] = 50; // 50 requests per hour per user/key
        //$this->load->model('analysedb');

    }

    public function hosts_get($client)
    {
        // Users from a data store e.g. database
        $hosts = $this->analysedb->hosts_get($client);
        if ($hosts)
        {
            // Set the response and exit
            $this->response($hosts, REST_Controller::HTTP_OK); // OK (200) being the HTTP response code
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

    public function host_delete($client, $host) {
        
        $result = $this->analysedb->host_delete($client, $host);

        if ($result === 0) {

            $message = [
                'host' => $host,
                'message' => 'Deleted the host'
            ];
    
            $this->set_response($message, REST_Controller::HTTP_OK); // NO_CONTENT (204) being the HTTP response code
        } else {
            $this->response("Failed to delete data for the host $host", REST_Controller::HTTP_BAD_REQUEST); // BAD_REQUEST (400) being the HTTP response code
        }
    }

    public function host_exists_name_get($client, $host) {

        if ($this->analysedb->host_exists_host_short_name($client, $host)) {
            $retval = ['host_exits' => 'exist'];
        } else {
            $retval = ['host_exits' => 'not exist'];
        }
        $this->set_response($retval, REST_Controller::HTTP_OK);
    }

    public function host_post() {
       
        $action = $this->post("action");
        $client = $this->post("client");
        $host_name_new = $this->post("host_name_new");
        $result = FALSE;

        if ($action == "update") {
            $host_name_old = $this->post("host_name_old");
            $result = $this->analysedb->host_update_names($client, $host_name_old, $host_name_new);
        }
        
        if ($result === TRUE) {

            $message = [
                'host_name' => $host_name_new,
                'message' => 'Updated the host'
            ];
    
            $this->set_response($message, REST_Controller::HTTP_OK); // NO_CONTENT (204) being the HTTP response code
        } else {
            $this->response("Failed to update data for the host $host_name_old", REST_Controller::HTTP_BAD_REQUEST); // BAD_REQUEST (400) being the HTTP response code
        }
    }
}
