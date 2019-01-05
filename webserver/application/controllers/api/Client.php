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
class Client extends REST_Controller {

    function __construct()
    {
        // Construct the parent class
        parent::__construct();

        // Configure limits on our controller methods
        // Ensure you have created the 'limits' table and enabled 'limits' within application/config/rest.php
        $this->methods['clients_get']['limit'] = 500; // 500 requests per hour per user/key
        $this->methods['client_post']['limit'] = 100; // 100 requests per hour per user/key
        //$this->methods['users_delete']['limit'] = 50; // 50 requests per hour per user/key
        //$this->load->model('analysedb');

    }

    public function clients_get()
    {
        // Users from a data store e.g. database
        $clients = $this->analysedb->clients_get();
        if ($clients)
        {
            // Set the response and exit
            $this->response($clients, REST_Controller::HTTP_OK); // OK (200) being the HTTP response code
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

    public function client_delete($client) {
       

        $result = $this->analysedb->client_delete($client);

        if ($result === 0) {

            $message = [
                'client' => $client,
                'message' => 'Deleted the client'
            ];
    
            $this->set_response($message, REST_Controller::HTTP_OK); // NO_CONTENT (204) being the HTTP response code
        } else {
            $this->response("Failed to delete data for the client $client", REST_Controller::HTTP_BAD_REQUEST); // BAD_REQUEST (400) being the HTTP response code
        }
    }

    public function client_exists_name_get($client) {

        if ($this->analysedb->client_exists_client_short_name($client)) {
            $retval = ['client_exits' => 'exist'];
        } else {
            $retval = ['client_exits' => 'not exist'];
        }
        $this->set_response($retval, REST_Controller::HTTP_OK);
    }

    public function client_post() {
       
        //get the parsed in arguments
        $action = $this->post("action");
        $client_name_new = $this->post("client_name_new");

        // set the default return value
        $result = FALSE;

        // if we are doing an update
        if ($action == "update") {
            $client_name_old = $this->post("client_name_old");
            $result = $this->analysedb->client_update_names($client_name_old, $client_name_new);
        }
        
        if ($result === TRUE) {

            $message = [
                'client_name' => $client_name_new,
                'message' => 'Updated the client'
            ];
    
            $this->set_response($message, REST_Controller::HTTP_OK); // NO_CONTENT (204) being the HTTP response code
        } else {
            $this->response("Failed to update data for the client $client_name_old", REST_Controller::HTTP_BAD_REQUEST); // BAD_REQUEST (400) being the HTTP response code
        }
    }

}
