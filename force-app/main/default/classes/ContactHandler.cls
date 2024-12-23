public with sharing class ContactHandler {
    public static void errorOnContact(List<Contact> contactList){
        //Assignment 8: If a Contact is created without a parent Account, do not allow the user to create the contact record
        if(!contactList.isEmpty()){
            for(Contact con : contactList){
                if(con.AccountId == null){
                    con.AccountId.addError('You cannot create contact without an Account');
                }
            }
        }
    }

    public static void preventDuplicate(List<Contact> contactList){
        List<Contact> contactsInOrg = [Select LastName, Email, Phone From Contact];
        if(!contactList.isEmpty()){
            for(Contact con : contactList){
                for(Contact existingcon : contactsInOrg){
                    if(con.LastName == existingcon.LastName && con.Email == existingcon.Email && con.Phone == existingcon.Phone){
                        con.addError('There is an existing contact with the same name, email and phone');
                    }
                }
            }
        }
    }

    public static void groupShare(List<Contact> contactList){
        //Assignment 17 Share the contact record with a public group as soon as a record is created.
        //NOTE: Set the Sharing setting on the contact to PRIVATE in the org to be able to deploy this code. 
        Group contactGroup = [Select Id, Name From Group where Name = 'ContactGroup'];
        List<ContactShare> contactShare = new List<ContactShare>();
        if(!contactList.isEmpty()){
            for(Contact con : contactList){
                ContactShare cs = new ContactShare();
                cs.ContactId = con.Id;
                cs.ContactAccessLevel = 'Edit';
                cs.UserOrGroupId = contactGroup.Id;
                contactShare.add(cs);
            }
        }

        if(!contactShare.isEmpty()){
            insert contactShare;
        }
    }

    public static void sendEmailToAccountOwner(List<Contact> contactList, Map<Id, Contact> oldConMap) {
        //Assignment 20: Send an email to the Account Owner when the email or phone of a child contact is modified.
        if (contactList.isEmpty() || oldConMap == null) {
            return; // Exit early if no contacts to process or no old data available
        }
    
        // Collect account IDs for modified contacts
        Set<Id> accountIds = new Set<Id>();
        Map<Id, String> emailBodiesByAccount = new Map<Id, String>();
    
        for (Contact con : contactList) {
            Contact oldCon = oldConMap.get(con.Id);
            if (oldCon != null && (con.Phone != oldCon.Phone || con.Email != oldCon.Email)) {
                String body = '';
                
                if (con.Phone != oldCon.Phone) {
                    body += 'The phone of the contact ' + con.LastName + ' has been modified. ' +
                            'Previous: ' + oldCon.Phone + ', New: ' + con.Phone + '. ';
                }
                if (con.Email != oldCon.Email) {
                    body += 'The email of the contact ' + con.LastName + ' has been modified. ' +
                            'Previous: ' + oldCon.Email + ', New: ' + con.Email + '.';
                }
    
                if (con.AccountId != null) {
                    accountIds.add(con.AccountId);
                    emailBodiesByAccount.put(con.AccountId, 
                        emailBodiesByAccount.get(con.AccountId) == null 
                            ? body 
                            : emailBodiesByAccount.get(con.AccountId) + '\n' + body);
                }
            }
        }
    
        if (accountIds.isEmpty()) {
            return; // Exit if no accounts are associated with modified contacts
        }
    
        // Retrieve account owners
        Map<Id, Id> accountOwnerMap = new Map<Id, Id>();
        for (Account acc : [SELECT Id, OwnerId FROM Account WHERE Id IN :accountIds]) {
            accountOwnerMap.put(acc.Id, acc.OwnerId);
        }
    
        // Retrieve owner emails
        Map<Id, String> ownerEmails = new Map<Id, String>();
        for (User owner : [SELECT Id, Email FROM User WHERE Id IN :accountOwnerMap.values() AND Email != null]) {
            ownerEmails.put(owner.Id, owner.Email);
        }
    
        // Prepare email messages
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for (Id accountId : emailBodiesByAccount.keySet()) {
            Id ownerId = accountOwnerMap.get(accountId);
            if (ownerEmails.containsKey(ownerId)) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new List<String>{ ownerEmails.get(ownerId) });
                email.setSubject('Contact Modification Notification');
                email.setPlainTextBody(emailBodiesByAccount.get(accountId));
                emails.add(email);
            }
        }
    
        // Send emails
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }    

    public static void mailingAddressOnContact(List<Contact> contactList){
        //Assignment 21: Whenever a Contact record is created, copy BillingAddress of Account to MailingAddress on Contact
        Set<Id> accIds = new Set<Id>();
        if(!contactList.isEmpty()){
            for(Contact con : contactList){
                if(con.AccountId != null){
                    accIds.add(con.AccountId);
                }
                For(Account acc : [Select Id, BillingStreet, BillingCity, BillingCountry, BillingState, BillingPostalCode From Account where Id in : accIds]){
                    con.MailingStreet = acc.BillingStreet;
                    con.MailingCity = acc.BillingCity;
                    con.MailingCountry = acc.BillingCountry;
                    con.MailingState = acc.BillingState;
                    con.MailingPostalCode = acc.BillingPostalCode;
                }
            }
        }
    }

    public static void avoidAdditionalContact(List<Contact> contactList){
        //Assignment 23: Do not allow Contact association if Max Contacts Allowed value is exceeded on the Account record.
        Set<Id> accIds = new Set<Id>();
        if(!contactList.isEmpty()){
            for(Contact con : contactList){
                if(con.AccountId != null){
                    accIds.add(con.AccountId);
                }
            }
        }
        Map<Id, Integer> accountIdToContactCount = new Map<Id, Integer>();
        Map<Id, Integer> accountIdToMaxContact = new Map<Id, Integer>();
        if(!accIds.isEmpty()){
            List<AggregateResult> countContacts = [Select AccountId, COUNT(Id) id From Contact where AccountId in : accIds group by AccountId];
            List<Account> accountList = [Select Id, Create_N_Contacts__c From Account where Id in : accIds];

            for(AggregateResult aggr : countContacts){
                for(Account acc: accountList){
                    if(aggr.get('AccountId') == acc.Id){
                        Integer contactCounts = (Integer)aggr.get('id');
                        Integer numberOfEmployees = Integer.valueOf(acc.Create_N_Contacts__c);
                        accountIdToContactCount.put(acc.Id, contactCounts);
                        accountIdToMaxContact.put(acc.Id, numberOfEmployees);
                    }
                }   
            }
        }

        if(!accountIdToContactCount.isEmpty()){
            for(Contact con : contactList){
                if(accountIdToMaxContact.containsKey(con.AccountId)){
                    Integer contactCounts = accountIdToContactCount.get(con.AccountId);
                    Integer numberOfEmployees = accountIdToMaxContact.get(con.AccountId);

                    if(contactCounts >= numberOfEmployees){
                        con.addError('You cannot create more contacts than the number of employees');
                    }
                }
            }
        }
    }
}