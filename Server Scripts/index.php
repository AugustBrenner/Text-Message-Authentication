<?php

// Helper method to get a string description for an HTTP status code
// From http://www.gen-x-design.com/archives/create-a-rest-api-with-php/ 
function getStatusCodeMessage($status)
{
    // these could be stored in a .ini file and loaded
    // via parse_ini_file()... however, this will suffice
    // for an example
    $codes = Array(
        100 => 'Continue',
        101 => 'Switching Protocols',
        200 => 'OK',
        201 => 'Created',
        202 => 'Accepted',
        203 => 'Non-Authoritative Information',
        204 => 'No Content',
        205 => 'Reset Content',
        206 => 'Partial Content',
        300 => 'Multiple Choices',
        301 => 'Moved Permanently',
        302 => 'Found',
        303 => 'See Other',
        304 => 'Not Modified',
        305 => 'Use Proxy',
        306 => '(Unused)',
        307 => 'Temporary Redirect',
        400 => 'Bad Request',
        401 => 'Unauthorized',
        402 => 'Payment Required',
        403 => 'Forbidden',
        404 => 'Not Found',
        405 => 'Method Not Allowed',
        406 => 'Not Acceptable',
        407 => 'Proxy Authentication Required',
        408 => 'Request Timeout',
        409 => 'Conflict',
        410 => 'Gone',
        411 => 'Length Required',
        412 => 'Precondition Failed',
        413 => 'Request Entity Too Large',
        414 => 'Request-URI Too Long',
        415 => 'Unsupported Media Type',
        416 => 'Requested Range Not Satisfiable',
        417 => 'Expectation Failed',
        500 => 'Internal Server Error',
        501 => 'Not Implemented',
        502 => 'Bad Gateway',
        503 => 'Service Unavailable',
        504 => 'Gateway Timeout',
        505 => 'HTTP Version Not Supported'
    );

    return (isset($codes[$status])) ? $codes[$status] : '';
}

// Helper method to send a HTTP response code/message
function sendResponse($status = 200, $body = '', $content_type = 'text/html')
{
    $status_header = 'HTTP/1.1 ' . $status . ' ' . getStatusCodeMessage($status);
    header($status_header);
    header('Content-type: ' . $content_type);
    echo $body;
}

class ConnectAPI {

    private $db;

    // Constructor - open DB connection
    function __construct() {
        $this->db = new mysqli('localhost', 'final321', 'G00682282', 'final321');
        $this->db->autocommit(FALSE);
    }

    // Destructor - close DB connection
    function __destruct() {
        $this->db->close();
    }

    // Main method to connect a user
    function connect() {
    
        
        // Check for required parameters

        /*  **** future improvment by modifying the posted parameters to make matches based
        on the vendor_id phone number and username to comodate for user switching phones
        or phones switching users, etc */
        if (isset($_POST["vendor_id"]) && isset($_POST["phone_number"])) {
        
            // Put parameters into local variables
            $vendor_id = $_POST["vendor_id"];
            $phone_number = $_POST["phone_number"];

            
            // Look up user in database

            /*  **** future improvment by modifying the querry to make matches based
            on the vendor_id phone number and username to comodate for user switching phones
            or phones switching users, etc */
            $id = 0;
            $stmt = $this->db->prepare('SELECT id FROM user_information WHERE vendor_id=? AND phone_number=?');
            $stmt->bind_param('ss', $vendor_id, $phone_number);
            $stmt->execute();
            $stmt->bind_result($id);
            while ($stmt->fetch()) {
                break;
            }
            $stmt->close();
            
            // if user doesnt exist, add user and generate unlock code
            if ($id <= 0) {
                $unlock_code = rand (111111, 999999);

                $stmt = $this->db->prepare('INSERT INTO user_information (vendor_id, phone_number, unlock_code) VALUES (?, ?, ?)');
                $stmt->bind_param('sss', $vendor_id, $phone_number, $unlock_code);
                $stmt->execute();
                $stmt->close();
                $this->db->commit();

                //send an a text to the user via SMS gateway

                /*  **** future improvment by modifying the mail to include more sms
                gateway adresses.  next improvement would be to use an SMS gateway provider
                to send 1 cent texts via API and final improvement would be to set up private
                SMS gateway */

                $to = $phone_number . "@txt.att.net";
                $subject = 'Your Unlock Code Is:';
                $message = $unlock_code;

                mail($to, $subject, $message);
                
                $result = array(
                "unlock_code" => $unlock_code,
                "phone_number" => $phone_number,
                "vendor_id" => $vendor_id
                );
                sendResponse(200, json_encode($result));
                return true;
            }
            else
            {
                sendResponse(403, 'User already registered');
                return false;
            }

            //expand list of conditions to make program robust

        }

        
        // Add  Number of of attempts so if they erroniously enter the code more than 3 times it returns user to phone number input screen
        if (isset($_POST["vendor_id"]) && isset($_POST["unlock_code"])) {
            $vendor_id = $_POST["vendor_id"];
            $unlock_code = $_POST["unlock_code"];

            $id = 0;
            $stmt = $this->db->prepare('SELECT id FROM user_information WHERE vendor_id=? AND unlock_code=?');
            $stmt->bind_param('ss', $vendor_id, $unlock_code);
            $stmt->execute();
            $stmt->bind_result($id);
            while ($stmt->fetch()) {
                break;
            }
            $stmt->close();

            if ($id > 0) {
                
                $this->db->query("UPDATE user_information SET confirmed='y' WHERE id=$id");
                $this->db->commit(); 
                $error = $this->db->error;
                
                $result = array(
                "vendor_id" => $vendor_id
                );

                sendResponse(200, json_encode($result));
                return true;

            }
            else
            {
                sendResponse(400, 'Invalid code');
                return false;
            }

        }

        if (isset($_POST["vendor_id"])) {
            $vendor_id = $_POST["vendor_id"];

            $id = 0;
            $stmt = $this->db->prepare('SELECT id, confirmed, phone_number FROM user_information WHERE vendor_id=?');
            $stmt->bind_param('s', $vendor_id);
            $stmt->execute();
            $stmt->bind_result($id, $confirmed, $phone_number);
            while ($stmt->fetch()) {
                break;
            }
            $stmt->close();

            if ($id > 0 && $confirmed == 'y') {
                
                $result = array(
                "confirmed" => "confirmed"
                );

                sendResponse(200, json_encode($result));
                return true;

            }
            else if($id > 0)
            {
                $result = array(
                "phone_number" => $phone_number
                );

                sendResponse(200, json_encode($result));
                return true;
            }
            else
            {
                sendResponse(404, 'No user found');
                return false;
            }

        }
        if (isset($_POST["first_name"]) && isset($_POST["last_name"]) && isset($_POST["contacts_phone_number"])) {

            $first_name = json_decode($_POST["first_name"]);
            $last_name = json_decode($_POST["last_name"]);
            $contacts_phone_number = json_decode($_POST["contacts_phone_number"]);

           
            $sanitized_phone_numbers = preg_replace('/[^\d]/','',$contacts_phone_number);
            $sql_formatted_contacts = implode(',', $sanitized_phone_numbers);
            
            $sql = 'SELECT confirmed, phone_number FROM user_information WHERE phone_number IN (' . $sql_formatted_contacts . ')';
            $result = $this->db->query($sql);
            $index = 0;
            while ($row = $result->fetch_assoc()) {
            $confirmed[$index] = $row["confirmed"];
            $phone_number[$index] = $row["phone_number"];
            $index++;
            }
            $result->free();
            $result->close();

                    //process names on client size to save server processing
                    for ($i = 0 ; $i < count($sanitized_phone_numbers) ; $i++){
                        
                        for ($j = 0 ; $j < count($phone_number) ; $j++){
                        
                            if ($sanitized_phone_numbers[$i] == $phone_number[$j] && $confirmed[$j] == 'y'){

                                $confirmed_first_name[$j] = $first_name[$i];
                                $confirmed_last_name[$j] = $last_name[$i];

                            }
                        }
                    } 
                    
                    $result = array(
                    "first_name" => $confirmed_first_name,
                    "last_name" => $confirmed_last_name,
                    "phone_number" => $phone_number,
                    );

                    sendResponse(200, json_encode($result));
                    return true;

        
            /*
            else if($id > 0)
            {
                $result = array(
                "phone_number" => $phone_number
                );

                sendResponse(200, json_encode($result));
                return true;
            }
            else
            {
                sendResponse(404, 'No user found');
                return false;
            }
            */
                
        }

    }

}

// This is the first thing that gets called when this page is loaded
// Creates a new instance of the connectAPI class and calls the connect method
$api = new ConnectAPI;
$api->connect();

?>