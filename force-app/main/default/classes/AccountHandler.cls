public with sharing class AccountHandler {
    public static void updateAccountError(List<Account> accList){
        //If an Account is updated and Ownership is set to Private, do not allow the user to save the record.
        if(!accList.isEmpty()){
            for(Account acc : accList){
                if(acc.Ownership == 'Private'){
                    acc.Ownership.addError('Private Ownership is not allowed');
                }
            }
        }
    }

    public static void updateContactWebsite(List<Account> accList){
        //Assignment 10: Every time an account website is updated, update the website field on all its child contacts
        Map<Id, String> idToWebMap = new Map<Id, String>();
        if(!accList.isEmpty()){
            for(Account acc : accList){
                if(acc.Website != null){
                    idToWebMap.put(acc.Id, acc.Website);
                }
            }
        }

        List<Contact> contactToUpdate = new List<Contact>();
        if(!idToWebMap.isEmpty()){
            List<Contact> conList = [Select AccountId, Name, Website__c From Contact where AccountId in :idToWebMap.keySet()];
            
            for(Contact con : conList){
                if(con.Website__c == null && con.Website__c != idToWebMap.get(con.AccountId)){
                    con.Website__c = idToWebMap.get(con.AccountId);
                    contactToUpdate.add(con);
                }
            }
        }

        if(!contactToUpdate.isEmpty()){
            update contactToUpdate;
        }
    }

    public static void createNEmployees(List<Account> accList){
        //Assignment 11: Create Contact records based on the Create N Contacts field on the Account record
        //Another task: if the numbers of contacts is less than the number of employees, then create the additional
        //Assignment 23: Do not allow Contact association if Max Contacts Allowed value is exceeded on the Account record.
        //This is similar to Case 28 (Creates the number of contacts which are equal to the number which we will enter in the Number of Locations field on the Account Object.)
        List<Contact> consToInsert = new List<Contact>();
        Map<Id, Integer> accountIdToContactCount = new Map<Id, Integer>();
        Set<Id> accIds = new Set<Id>();
        if(!accList.isEmpty()){
            for(Account acc : accList){
                accIds.add(acc.Id);
            }
        }

        if(!accIds.isEmpty()){
            List<AggregateResult> countContacts = [Select AccountId, COUNT(Id) id From Contact where AccountId in : accIds group by AccountId];

            for(AggregateResult aggr : countContacts){
                Id accountId = (Id)aggr.get('AccountId');
                Integer count = (Integer)aggr.get('id');
                accountIdToContactCount.put(accountId, count);
            }
        }

        if(!accountIdToContactCount.isEmpty()){
            for(Account acc : accList){
                if(accountIdToContactCount.containsKey(acc.Id)){
                    Integer contactCounts = accountIdToContactCount.get(acc.Id);
                    Integer numberOfEmployees = Integer.valueOf(acc.Create_N_Contacts__c);

                    if(contactCounts < numberOfEmployees){
                        Integer difference = (numberOfEmployees - contactCounts);
                        for(Integer i = 0; i < difference; i++){
                            Contact con = new Contact();
                            con.AccountId = acc.Id;
                            con.LastName = acc.Name;
                            con.FirstName = 'Employee' + (i + 1);
                            consToInsert.add(con);   
                        }
                    }
                }
            }
        }

        if(!consToInsert.isEmpty()){
            insert consToInsert;
        }
    }

    public static void createContactAuto(List<Account> accList){
        //Assignment 26: Create a Contact record automatically whenever an Account is created. This is the same for Case 33 (Create a related Contact when an Account is created)
        List<Contact> consToInsert = new List<Contact>();
        List<Opportunity> oppsToInsert = new List<Opportunity>();
        if(!accList.isEmpty()){
            for(Account acc : accList){
                Contact con = new Contact();
                con.AccountId = acc.Id;
                con.LastName = acc.Name;
                con.FirstName = 'Employee';
                if(acc.Industry == 'Banking' && acc.Phone != null){
                    //Assignment 27: If the Industry is Banking, then copy the Phone field from Account to Contact
                    con.Phone = acc.Phone;
                }
                if(acc.Industry == 'Media'){
                    //Assignment 28: If the Industry is Media, then set the Rating field on Account to Hot
                    acc.Rating = 'Hot';
                }

                if(acc.CopyBillingToShipping__c == true){
                    //Assignment 31: If the Copy Billing to Shipping field is checked, then copy the Billing Address to Shipping Address
                    acc.BillingStreet = acc.ShippingStreet;
                    acc.BillingCity = acc.ShippingCity;
                    acc.BillingCountry = acc.ShippingCountry;
                    acc.BillingState = acc.ShippingState;
                    acc.BillingPostalCode = acc.ShippingPostalCode;
                }

                // Assignment 34: Create a related Opportunity when an Account is created.
                Opportunity opp = new Opportunity();
                opp.AccountId = acc.Id;
                opp.Name = 'Auto Created opportunity for ' + acc.Name;
                opp.StageName = 'Prospecting';
                opp.CloseDate = Date.today() + 30;
                oppsToInsert.add(opp);
                consToInsert.add(con);
            }
        }
        List<SObject> sobjList = new List<SObject>();
        if(!consToInsert.isEmpty() && !oppsToInsert.isEmpty()){
            sobjList.addAll(consToInsert);
            sobjList.addAll(oppsToInsert);
        }

        insert sobjList;
    }

    public static void setActiveOnUndelete(List<Account> accList){
        //Assignment 37: Undelete Account/Employee record and set Active as “true”.
        //Assignment 43: When an account record is restored from the bin, update its name, prefix it with the “Restored” keyword.
        List<Account> accToUpdate = new List<Account>();
        if(!accList.isEmpty()){
            for(Account acc : accList){
                Account newAcc = new Account();
                newAcc.Id = acc.Id;
                newAcc.Active__c = 'Yes';
                newAcc.Name = 'Restored ' + acc.Name;
                accToUpdate.add(newAcc);
            }
        }

        if(!accToUpdate.isEmpty()){
            update accToUpdate;
        }
    }

    public static void SetSalesRep(List<Account> accList){
        if(!accList.isEmpty()){
            for(Account acc : accList){
                acc.Sales_Rep__c = UserInfo.getName();
            }
        }
    }
}