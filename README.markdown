## Introduction

Malaria Referral System is a web base application with SMS service that  enable the health center staff (HC)
Private Provider via SMS to the system and make automatic SMS alert. It is built on top of Malaria Day Cero System as an extra module.

## Overview

Reports indicate that more than 70% of malaria patients in Cambodia seek treatment via the private sector.   The Public-Private Mix (PPM) project, initiated by the Cambodia National Malaria Program (CNM) and partners, uses public sector staff to help select and train registered private providers in accordance with National Treatment Guidelines (NTG’s).  Among other things, private providers receive training on appropriate diagnosis, treatment and referral procedures.  In accordance with NTG’s, private providers in malaria risk zones 2 and3 are permitted to diagnose and treat malaria cases although, children under five, pregnant women, and cases of serious/recurrent malaria should be referred to the public sector while private providers in malaria risk zone 1 should refer all malaria patients to the public sector.  
Mechanisms are in place to gather case data from selected private providers; however, it continues to be problematic to track referrals from the private to the public sector.  This population is often lost to follow up once they leave the private provider’s facility.  The SMS based system being proposed is designed to help more effectively track patients and determine what happens to them after they are referred:  do patients continue seeking treatment, where do they go,  why don’t they go to the public sector, etc?  Without the implementation of a tracking mechanism for these cases, it is impossible to know if these important patients are receiving the treatment they need. 

## Objectives

To develop an SMS system to more effectively track patients that are referred from the private to the public sector.
Specific Objectives
  * Follow up patients referred from registered private provider (PP) and monitor whether an SMS system was used to alert the corresponding health facility
  * To Follow up patients that never reached the health facility and assess what determining factors contributed to not accessing the public sector
  * To assess the user friendliness and acceptability of the SMS referral system to the private providers, the patient, and the public health facilities



## Features

  * Integrate with Malaria day zero alert system
  * Register private provider and health center staff to send and receive SMS
  * Register dynamic field(s) to receive SMS report from private provider and health center staff
  * Add validation for dynamic field
  * Design its own accepted SMS format dynamically
  * Ability to define different accepted SMS format for private provider and health center
  * Customizable system reply SMS templates
  * Report dashboard


## SMS Accepted format

There are predefined fields for constructing sms accepted format for private provider and health center 
 
  *  {phone_number} {od} {book_number} {code_number} {slip_code} {health_center}

There are also dynamic fields to be defined on the fly and will be available along with predefined fields to construct Accepted SMS ej:

## Private provider accepted SMS
  * {phone_number} {od} {book_number} {code_number} {slip_code} {health_center} {malaria_type} {sex} {number_of_day_affected}

## Health center accepted SMS

  * {slip_code} {number_of_day_number_of_day_treatment}

## Where 

{malaria_type}, {sex}, {number_of_day_affected},{number_of_day_number_of_day_treatment} are dynamic fields defined by Admin.
