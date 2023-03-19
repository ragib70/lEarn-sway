contract;

use std::{
    storage::StorageMap,
    auth::{
        AuthError,
        msg_sender,
    },
    block::timestamp,
    context::msg_amount,
    hash::sha256,
    call_frames::msg_asset_id,
    constants::BASE_ASSET_ID,
    token::transfer_to_address
    };

struct course_info{
    creator_address : Identity,
    course_fee : u64,
    num_sections : u64,
    section_deadlines : [u64; 25],
    section_refund_fee : [u64; 25],
    enrolled_students : [Identity; 25],
    curr_enrollment_count : u64
}

struct user_course_info{
    time_enrolled : u64,
    sections_completed: [u64; 25]
}

struct user_custom_database{
    user : Identity,
    enrolled_courses_id : [u64; 25],
    sections_completed : [[u64; 25]; 25]
}

storage {
    course_id: u64 = 0,
    course_database: StorageMap<u64, course_info> = StorageMap {},
    user_enrolled_database: StorageMap<b256, user_course_info> = StorageMap{},
    contract_balance: u64 = 0
}

abi lEarn {
    #[storage(read, write)]
    fn create_course(_course_fee: u64, _num_sections: u64, _kachra_array: Vec<u64>, _generic_input_array: Vec<u64>) -> course_info;

    #[storage(read)]
    fn get_course_database(_course_id: u64) -> course_info;

    #[storage(read)]
    fn get_course_id() -> u64;

    #[storage(read,write), payable]
    fn enroll_course(_course_id: u64);

    #[storage(read)]
    fn get_user_database(_course_id : u64) -> user_course_info;

    #[storage(read)]
    fn get_contract_balance() -> u64;

    #[storage(read, write)]
    fn section_completed(_course_id : u64, _section_id : u64); 

    #[storage(read)]
    fn get_user_data() -> user_custom_database; 
}

//Utitlity function to claculate timestamp.
// fn calculate_timestamp(_course_id : u64, _section_id : u64, _num_sections : u64, _section_deadlines : [u64; 25]) -> u64{

//     require(_num_sections > _section_id, "Invalid Section");

//     let mut _cumm_timestamp : u64 = 0;
//     let mut i : u64 = 0;
//     while i < _section_id + 1 {
//         _cumm_timestamp += _section_deadlines[i];
//     }

//     return _cumm_timestamp;
// }

impl lEarn for Contract {

    #[storage(read)]
    fn get_user_data() -> user_custom_database {
        
        let temp : user_course_info = user_course_info{
            time_enrolled : 0,
            sections_completed : [55; 25]
        };

        let _user : Identity = msg_sender().unwrap();
        
        let mut _num_courses_enrolled : u64 = 0;
        let mut _course_id : u64 = 0;
        while _course_id < storage.course_id {
            let _key : b256 = sha256((msg_sender().unwrap(), _course_id));
            if(storage.user_enrolled_database.get(_key).unwrap_or(temp).time_enrolled != 0){
                _num_courses_enrolled += 1;
            }
            _course_id += 1;
        }

        let mut _courses_array : [u64; 25] = [999999; 25];
        let mut _sections_completed : [[u64; 25]; 25] = [[2; 25]; 25];

        _course_id = 0;
        let mut _count : u64 = 0;
        while _course_id < storage.course_id {
            let _key : b256 = sha256((msg_sender().unwrap(), _course_id));
            if(storage.user_enrolled_database.get(_key).unwrap_or(temp).time_enrolled != 0){
                _courses_array[_count] = _course_id;
                _sections_completed[_count] = storage.user_enrolled_database.get(_key).unwrap().sections_completed;
                _count += 1; 
            }
            _course_id += 1;
        }

        let _curr_user_info : user_custom_database = user_custom_database {
            user : _user,
            enrolled_courses_id : _courses_array,
            sections_completed : _sections_completed
        };
        
        return _curr_user_info;

    }


    #[storage(read, write)]
    fn section_completed(_course_id : u64, _section_id : u64) {

        let temp : user_course_info = user_course_info{
            time_enrolled : 0,
            sections_completed : [55; 25]
        };
        //Sanity check incorrect course id.
        require(_course_id < storage.course_id, "Invalid course id.");

        //Sanity Check that the user is enrolled also or not.
        let _key = sha256((msg_sender().unwrap(), _course_id));
        require(storage.user_enrolled_database.get(_key).unwrap_or(temp).time_enrolled != 0, "User has not enrolled in this course");

        //Sanity check whether it has already completed the course or not and re-claiming the refund.
        require(storage.course_database.get(_course_id).unwrap().num_sections > _section_id, "Invalid Section");
        require(storage.user_enrolled_database.get(_key).unwrap().sections_completed[_section_id] == 0, "Section already completed refund isssued.");

        //Calculate the exact timestamp to refund amount.
        // let _cumm_timestamp : u64 = calculate_timestamp(_course_id, _section_id, storage.course_database.get(_course_id).unwrap().num_sections, storage.course_database.get(_course_id).unwrap().section_deadlines);
        // let _exact_deadline : u64 = storage.user_enrolled_database.get(_key).unwrap().time_enrolled + _cumm_timestamp; 

        // require(timestamp() <= _exact_deadline, "Deadline passed refund not possible.");

        //Since sanity checks passed now we can refund the amount.
        let current_balance = storage.contract_balance;
        assert(current_balance >= storage.course_database.get(_course_id).unwrap().section_refund_fee[_section_id]);

        storage.contract_balance = current_balance - storage.course_database.get(_course_id).unwrap().section_refund_fee[_section_id];

        // Note: `transfer_to_address()` is not a call and thus not an
        // interaction. Regardless, this code conforms to
        // checks-effects-interactions to avoid re-entrancy.
        let raw_address: b256 = 0xa5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5; 
        let mut _refund_address : Address = Address::from(raw_address);
        let sender: Result<Identity, AuthError> = msg_sender();
        if let Identity::Address(address) = sender.unwrap() {
            _refund_address = address;
        } else {
            revert(0);
        }
        transfer_to_address(storage.course_database.get(_course_id).unwrap().section_refund_fee[_section_id], BASE_ASSET_ID, _refund_address);

        //Update the user course database.
        let _time_enrolled : u64 = storage.user_enrolled_database.get(_key).unwrap().time_enrolled;
        let mut _sections_completed : [u64; 25] = storage.user_enrolled_database.get(_key).unwrap().sections_completed;
        
        _sections_completed[_section_id] = 1;

        let value : user_course_info = user_course_info{
            time_enrolled : _time_enrolled,
            sections_completed : _sections_completed
        };

        storage.user_enrolled_database.insert(_key, value);
    }

    #[storage(read,write), payable]
    fn enroll_course(_course_id: u64) {

        require(msg_asset_id() == BASE_ASSET_ID, "Invalid Token");
        //Sanity check incorrect course id.
        require(_course_id < storage.course_id, "Invalid course id.");

        //Sanity check to prevent mutliple enrolling.
        let mut i: u64 = 0;
        
        while i < storage.course_database.get(_course_id).unwrap().curr_enrollment_count {
            require(msg_sender().unwrap() != storage.course_database.get(_course_id).unwrap().enrolled_students[i], "Student already enrolled");
            i += 1;
        }
        
        //Deposit fee also and if the user doesn't have amount equal to fees revert the transaction.
        require(msg_amount() == storage.course_database.get(_course_id).unwrap().course_fee, "Incorrect course fee amount");

        //Update the user course database.
        let _key = sha256((msg_sender().unwrap(), _course_id));
        let _time_enrolled : u64 = timestamp();
        let mut _sections_completed : [u64; 25] = [2; 25];
        i = 0;
        while i < storage.course_database.get(_course_id).unwrap().num_sections {
            _sections_completed[i] = 0;
            i += 1;
        }
        let value : user_course_info = user_course_info{
            time_enrolled : _time_enrolled,
            sections_completed : _sections_completed
        };

        storage.user_enrolled_database.insert(_key, value);

        //Add the msg_sender in the enrolled student array in the course database
        let _curr_enrollment_count : u64 = storage.course_database.get(_course_id).unwrap().curr_enrollment_count; 
        //Create a new array, copy the working array and then mutate it.
        let mut temp_es : [Identity; 25] = storage.course_database.get(_course_id).unwrap().enrolled_students;
        temp_es[_curr_enrollment_count] = msg_sender().unwrap();


        let curr_course: course_info = course_info{
            creator_address : storage.course_database.get(_course_id).unwrap().creator_address,
            course_fee :  storage.course_database.get(_course_id).unwrap().course_fee,
            num_sections : storage.course_database.get(_course_id).unwrap().num_sections,
            section_deadlines : storage.course_database.get(_course_id).unwrap().section_deadlines,
            section_refund_fee : storage.course_database.get(_course_id).unwrap().section_refund_fee,
            enrolled_students : temp_es,
            curr_enrollment_count : storage.course_database.get(_course_id).unwrap().curr_enrollment_count + 1
        };

        storage.course_database.insert(_course_id, curr_course);
        //Add the msg_value to the contract balance.
        storage.contract_balance += msg_amount();

    }
    
    #[storage(read)]
    fn get_course_id() -> u64 {

        return storage.course_id;

    }

    #[storage(read)]
    fn get_contract_balance() -> u64{

        return storage.contract_balance;

    }

    #[storage(read)]
    fn get_user_database(_course_id : u64) -> user_course_info {
        
        require(_course_id < storage.course_id, "Invalid Course Id");
        
        let _key = sha256((msg_sender().unwrap(), _course_id));

        return storage.user_enrolled_database.get(_key).unwrap();

    }

    #[storage(read)]
    fn get_course_database(_course_id: u64) -> course_info {

        return storage.course_database.get(_course_id).unwrap();

    }

    #[storage(read, write)]
    fn create_course(_course_fee: u64, _num_sections: u64, _kachra_array: Vec<u64>, _generic_input_array: Vec<u64>) -> course_info {

        // Update the database from the input parameters.
        let mut temp_vec_sd : [u64; 25] = [999999; 25];
        let mut temp_vec_srf : [u64; 25] = [999999; 25];
        let raw_address: b256 = 0xa5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5;                                
        let my_identity: Identity = Identity::Address(Address::from(raw_address));
        let mut temp_vec_es : [Identity; 25] = [my_identity; 25];
        
        // require(_section_deadline.get(0).unwrap() == 10, "Section Deadline input wrong at index 0");

        let mut i: u64 = 0;
        let mut j: u64 = _num_sections;
        while i < _num_sections{
            temp_vec_sd[i] = _generic_input_array.get(i).unwrap();
            temp_vec_srf[i] = _generic_input_array.get(j).unwrap();
            i += 1;
            j += 1;
        }

        // require(temp_vec_sd[0] == 10, "Temp vector wrong at index 0");

        let sender : Identity = msg_sender().unwrap();

        let curr_course: course_info = course_info{
            creator_address : sender,
            course_fee :  _course_fee,
            num_sections : _num_sections,
            section_deadlines : temp_vec_sd,
            section_refund_fee : temp_vec_srf,
            enrolled_students : temp_vec_es,
            curr_enrollment_count : 0
        };

        // require(curr_course.section_deadlines[0] == 10, "Cur Course wrong");

        storage.course_database.insert(storage.course_id, curr_course);

        // Increment the counter as the courseId counter gives the index of the next course going to be created.
        storage.course_id = storage.course_id + 1;
        return curr_course;

    }
}
