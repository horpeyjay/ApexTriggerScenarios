public with sharing class CaseHandler {
    //Assignment 3 Whenever a Case is created & Case Origin is “Phone”, Set Priority as “High”, else set Priority as “Low”.
    //added Assignment 24 Whenever a case is created with origin as “email” then set status as “new” and Priority as “Medium”.
    public static void caseStatusUpdate(List<Case> caseList){
        if(!caseList.isEmpty()){
            for(Case c : caseList){
                if(c.Origin == 'Phone'){
                    c.Priority = 'High';
                }else if(c.Origin == 'Email'){
                    c.Priority = 'Medium';
                    c.Status = 'New';
                }else{
                    c.Priority = 'Low';
                }
            }
        }
    }

    public static void preventCaseDeletion(List<Case> caseList){
        // Assignment 16: Allow Case Deletion only by “System Admin users”.
        Profile adminProfile = [Select Id, Name From Profile where Name = 'System Administrator'];

        if(UserInfo.getProfileId() != adminProfile.Id){
            for(Case c : caseList){
                c.addError('You cannot delete a case. Only a system admin can delete case');
            }
        }
    }

    public static void updateCaseNumOnAccount(List<Case> caseList){
        //Assignment 35: When a Case is created on any Account, put the latest case number on the Account in the “Latest Case Number” field.
        Set<Id> accIds = new Set<Id>();
        if(!caseList.isEmpty()){
            for(Case c : caseList){
                if(c.AccountId != null){
                    accIds.add(c.AccountId);
                }
            }
        }
        List<Account> accountToUpdate = new List<Account>();
        if(!accIds.isEmpty()){
            for(Account acc : [Select Id, Latest_Case_Number__c From Account where Id in : accIds]){
                for(Case c : caseList){
                    if(acc.Id == c.AccountId){
                        acc.Latest_Case_Number__c = c.CaseNumber;
                        accountToUpdate.add(acc);
                    }
                }
            }
        }
        if(!accountToUpdate.isEmpty()){
            update accountToUpdate;
        }
    }
}