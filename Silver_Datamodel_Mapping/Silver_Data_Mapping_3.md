_____________________________________________
## *Author*: AAVA
## *Created on*:   11-11-2025
## *Description*: Comprehensive data mapping for Silver Layer in Zoom Platform Analytics System Medallion architecture with enhanced timestamp format validation and critical DQ checks
## *Version*: 3 
## *Updated on*: 11-11-2025
## *Changes*: Added two new critical DQ checks - SI_MEETINGS duration text cleaning (Section 2.8) and SI_LICENSES DD/MM/YYYY date format conversion (Section 7.6)
## *Reason*: Address specific data conversion failures - "108 mins" error in SI_MEETINGS and "27/08/2024" DD/MM/YYYY format error in SI_LICENSES
_____________________________________________

# Silver Layer Data Mapping
## Zoom Platform Analytics System

## 1. Overview

This document provides a comprehensive data mapping from the Bronze Layer to the Silver Layer for the Zoom Platform Analytics System following Medallion architecture principles. The mapping incorporates necessary cleansing