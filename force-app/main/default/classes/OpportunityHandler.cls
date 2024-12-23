public with sharing class OpportunityHandler {
    public static void createTaskOnClosedWon(List<Opportunity> oppList){
        //Assignment 5: Whenever an Opportunity is “Closed Won”, create a Task for the Opportunity Owner to split revenue.
        List<Task> taskToCreate = new List<Task>();
        if(!oppList.isEmpty()){
            Task t = new Task();
            for(Opportunity opp : oppList){
                if(opp.StageName == 'Closed Won'){
                    
                    t.Subject = 'Create Opportunity Split';
                    t.WhatId = opp.Id;
                    t.Priority = 'High';
                    t.OwnerId = opp.OwnerId;
                    t.ActivityDate = Date.today() + 3;
                    taskToCreate.add(t);
                }else if(opp.StageName != 'Closed Lost' || opp.StageName != 'Prospecting'){
                    t.Subject = 'Follow-up with customer';
                    t.WhatId = opp.Id;
                    t.Priority = 'Medium';
                    t.ActivityDate = Date.today() + 5;
                    t.OwnerId = opp.OwnerId;
                    taskToCreate.add(t);
                }
            }
        }
        if(!taskToCreate.isEmpty()){
            insert taskToCreate;
        }
    }

    public static void modifyAmount(List<Opportunity> oppList, Map<Id, Opportunity> oldOppsMap){
        //If the Opportunity Stage is Modified, update Opportunity Amount
        List<Account> accountToUpdate = new List<Account>();
        if(!oppList.isEmpty()){
            for(Opportunity opp : oppList){
                if(oldOppsMap == null){
                    //Assignment 30: Upon Opportunity Creation if Amount is not null and is greater than “100000” then populate “Hot  Opportunity” in the description field.
                    Account acc = new Account();
                    acc.Id = opp.AccountId;
                    //Assignment 36: Account records should have a field named “Recent Opportunity Amount”. It should contain the opportunity amount of the latest created opportunity on account.
                    if(opp.Amount != null){
                        if(opp.AccountId != null){ 
                            acc.Recent_Opportunity_Amount__c = opp.Amount;
                            if( opp.Amount >= 100000){
                                opp.Description = 'Hot Opportunity';
                                
                            }
                        }else{
                            acc.Recent_Opportunity_Amount__c = opp.Amount;
                        }
                    }else{
                        acc.Recent_Opportunity_Amount__c = 0;
                    }
                    accountToUpdate.add(acc);
                }else{
                    Opportunity oldOpp = new Opportunity();
                    Opportunity newOpp = new Opportunity();
                    if(oldOppsMap != null){
                        oldOpp = oldOppsMap.get(opp.Id);
                        if(opp.StageName != oldOpp.StageName && oldOpp.StageName == 'Closed Lost'){
                            newOpp.Id = opp.Id;
                            newOpp.Amount = (opp.Amount * opp.Probability) / 100;
                        }
                    } 
                }
            }
        }

        if(!accountToUpdate.isEmpty()){
            update accountToUpdate;
        }
    }

    public static void createTaskOnDelete(List<Opportunity> oppList){
        //Assignment 13: As soon as an Opportunity is deleted, create a Task for the Opportunity’s parent Account Owner
        Map<Id, List<Opportunity>> ownerToOppMap = new Map<Id, List<Opportunity>>();
        Set<Id> accIds = new Set<Id>();
        if(!oppList.isEmpty()){
            List<Opportunity> multipleOpps = new List<Opportunity>();
            for(Opportunity opp : oppList){
                if(opp.AccountId != null){
                    accIds.add(opp.AccountId);
                }
            }

            if(!accIds.isEmpty()){
                List<Account> accountList = [Select Id, OwnerId From Account where Id in : accIds];

                for(Account acc : accountList){
                   for(Opportunity opp : oppList){
                        if(acc.Id == opp.AccountId){
                            if(!ownerToOppMap.containsKey(acc.OwnerId)){
                                multipleOpps.add(opp);
                                ownerToOppMap.put(acc.OwnerId, multipleOpps);
                            }else{
                                ownerToOppMap.get(acc.OwnerId).add(opp);
                            }
                        }
                   }
                }
            }
        }
        List<Task> taskInsert = new List<Task>();
        if(!ownerToOppMap.isEmpty()){
            for(Id ownerId : ownerToOppMap.keySet()){
                for(Opportunity opp : ownerToOppMap.get(ownerId)){
                    Task t = new Task();
                    t.Subject = 'Deleted Opportunity on ' + opp.Name;
                    t.Priority = 'High';
                    t.ownerId = ownerId;
                    taskInsert.add(t);
                }
            }
        }

        if(!taskInsert.isEmpty()){
            insert taskInsert;
        }
    }
    
    public static void deleteOpportunityTeamMembers(List<Opportunity> oppList){
        //Assignment 15: As soon as Opportunity is “Closed Lost”, remove all Opportunity Team Members from the Opportunity.
        Set<Id> closeLostIds = new Set<Id>();
        if(!oppList.isEmpty()){
            for(Opportunity opp : oppList){
                if(opp.StageName == 'Closed Lost'){
                    closeLostIds.add(opp.Id);
                }
            }
        }

        if(!closeLostIds.isEmpty()){
            List<OpportunityTeamMember> oppTeamMember = [Select Id, OpportunityId From OpportunityTeamMember where OpportunityId in : closeLostIds];
            if(!oppTeamMember.isEmpty()){
                delete oppTeamMember;
            }
        }
    }

    public static void assignRoleTeamMembers(List<Opportunity> oppList){
        //Assignment 18: As soon as an Opportunity is created with StageName as “Needs Analysis”, assign all the users with Role as “Opportunitists” to the Opportunity.
        List<User> userList = [SELECT Id, Name FROM User WHERE UserRole.Name = 'Opportunitists'];
        List<OpportunityTeamMember> otmList = new List<OpportunityTeamMember>();
        if(!oppList.isEmpty()){
            for(Opportunity opp : oppList){
                if(opp.StageName == 'Needs Analysis'){
                    for(User u  : userList){
                        OpportunityTeamMember otm = new OpportunityTeamMember();
                        otm.OpportunityId = opp.Id;
                        otm.OpportunityAccessLevel = 'Read';
                        otm.UserId = u.Id;
                        otm.TeamMemberRole = 'Opportunitists';
                        otmList.add(otm);
                    }
                }
            }
        }
        if(!otmList.isEmpty()){
            insert otmList;
        }
    }

    public static void sendEmailToOwnerAndTeam(List<Opportunity> oppList) {
        //Assignment 39: If an Opportunity is Closed Won, send email to opportunity owner, account owner & team members.
        if (oppList.isEmpty()) {
            return; // Exit early if no opportunities are provided
        }
    
        Set<Id> oppIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        for (Opportunity opp : oppList) {
            if (opp.StageName == 'Closed Won') {
                oppIds.add(opp.Id);
                accountIds.add(opp.AccountId);
            }
        }
    
        Map<Id, Set<Id>> oppTeamMembersMap = new Map<Id, Set<Id>>();
        for (OpportunityTeamMember otm : [SELECT OpportunityId, UserId FROM OpportunityTeamMember WHERE OpportunityId IN :oppIds]) {
            if (!oppTeamMembersMap.containsKey(otm.OpportunityId)) {
                oppTeamMembersMap.put(otm.OpportunityId, new Set<Id>());
            }
            oppTeamMembersMap.get(otm.OpportunityId).add(otm.UserId);
        }
    
        Map<Id, Id> accountOwnerMap = new Map<Id, Id>();
        for (Account acc : [SELECT Id, OwnerId FROM Account WHERE Id IN :accountIds]) {
            accountOwnerMap.put(acc.Id, acc.OwnerId);
        }
    
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for (Opportunity opp : oppList) {
            if (opp.StageName == 'Closed Won') {
                Set<Id> recipientIds = new Set<Id>();
                recipientIds.add(opp.OwnerId); // Add Opportunity Owner
    
                // Add Opportunity Team Members
                if (oppTeamMembersMap.containsKey(opp.Id)) {
                    recipientIds.addAll(oppTeamMembersMap.get(opp.Id));
                }
    
                // Add Account Owner
                if (accountOwnerMap.containsKey(opp.AccountId)) {
                    recipientIds.add(accountOwnerMap.get(opp.AccountId));
                }
    
                // Query Users for Email Addresses
                List<User> users = [SELECT Id, Email FROM User WHERE Id IN :recipientIds];
                List<String> toAddresses = new List<String>();
                for (User user : users) {
                    toAddresses.add(user.Email);
                }

                if (!toAddresses.isEmpty()) {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(toAddresses);
                    mail.setSubject('Opportunity Closed Won');
                    mail.setPlainTextBody('The Opportunity ' + opp.Name + ' has been Closed Won and it is time to celebrate!');
                    emails.add(mail);
                }
            }
        }
    
        // Send Emails
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
}