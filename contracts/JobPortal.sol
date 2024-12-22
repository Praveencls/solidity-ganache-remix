// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract JobPortal {
    
    address public admin;

    modifier onlyAdmin {
        require(admin == msg.sender, "Only admin can access this function.");
        _;
    }

    struct Applicant {
        uint id;
        string name;
        uint256 age;
        string expectedJobType;
        string[] skills;
        string domain;
    }

    struct JobDescription {
        string companyName;
        string jobRole;
        string requiredExperience;
        uint salaryPerAnnum;
        string workLocationType;
        uint openings;
    }

    // Mapping from Id to applicants
    mapping (uint => Applicant) public applicantId;

    // Array to store all the jobs
    JobDescription[] public jobs;

    // Mapping to connect applicants to the jobs they applied to
    mapping (uint => JobDescription[]) public jobApplications;

    // Mapping to connect applicant Id to their rating
    mapping (uint => string) public applicantRating;

    // Mapping for job roles to avoid looping through all jobs
    mapping (string => JobDescription[]) public jobsByRole;

    // Initial data allocation
    constructor() {
        admin = msg.sender;
    }

    // Function to add job applicants to the array by the admin
    function addJobApplicant(uint _id, string memory _name, uint _age, string memory _expectedJobType, string[] memory _skills, string memory _domain) public onlyAdmin {
        applicantId[_id] = Applicant(_id, _name, _age, _expectedJobType, _skills, _domain);
    }

    // Function to get the application details from the blockchain
    function getApplicantDetails(uint _id) public view returns (uint, string memory, uint, string memory, string[] memory, string memory) {
        Applicant storage applicant = applicantId[_id];
        return (applicant.id, applicant.name, applicant.age, applicant.expectedJobType, applicant.skills, applicant.domain);
    }

    // Function to get the type of applicant based on the domain of working
    function getApplicantType(uint _id) public view returns (string memory) {
        return applicantId[_id].domain;
    }

    // Function to add new job -- can be added only by the admin
    function addJob(string memory _companyName, string memory _jobRole, string memory _requiredExperience, uint _salaryPerAnnum, string memory _workLocationType, uint _openings) public onlyAdmin {
        JobDescription memory newJob = JobDescription(_companyName, _jobRole, _requiredExperience, _salaryPerAnnum, _workLocationType, _openings);
        jobs.push(newJob);
        jobsByRole[_jobRole].push(newJob); // Store jobs by role for quick access
    }

    // Function to show the available jobs based on role
    function getJobDetails(string memory _jobRole) public view returns (JobDescription[] memory) {
        JobDescription[] memory availableJobs = jobsByRole[_jobRole];
        require(availableJobs.length > 0, "Job not found.");
        return availableJobs;
    }

    // Function to apply for a job
    function applyForJobs(uint _id, string memory _jobRole) public {
        JobDescription[] storage availableJobs = jobsByRole[_jobRole];
        require(availableJobs.length > 0, "No jobs available for this role.");

        for (uint i = 0; i < availableJobs.length; i++) {
            if (availableJobs[i].openings > 0) {
                // Store job application
                jobApplications[_id].push(availableJobs[i]);

                // Decrease job opening count
                availableJobs[i].openings--;

                return; // Exit after applying for the first available job
            }
        }
        revert("No job found.");
    }

    // Function to get the jobs that a candidate has applied for
    function getAppliedJobs(uint _id) public view returns (JobDescription[] memory) {
        return jobApplications[_id];
    }

    // Function to provide rating to the applicants
    function giveApplicantRating(uint _id, string memory _rating) public {
        applicantRating[_id] = _rating;
    }

    // Function to fetch the applicant rating
    function getApplicantRating(uint _id) public view returns (string memory) {
        return applicantRating[_id];
    }
}
