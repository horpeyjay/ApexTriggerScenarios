public with sharing class AccountBatchable implements Database.Batchable<SObject>{
    //Assignment 42: Use Async apex to update related contacts when the parent account industry is changed to “Biotechnology”.
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([Select Id, Name, BillingCity, BillingState, BillingCountry From Account where Industry = 'Biotechnology']);
    }

    public void execute(Database.BatchableContext bc, List<Account> scope){
        List<Contact> contactToUpdate = new List<Contact>();
        for(Account acc : scope){
            for(Contact con : [Select Id, Name From Contact where AccountId = : acc.Id]){
                con.MailingCity = acc.BillingCity;
                con.MailingState = acc.BillingState;
                con.MailingCountry = acc.BillingCountry;
                contactToUpdate.add(con);
            }
        }

        if(!contactToUpdate.isEmpty()){
            update contactToUpdate;
        }
    }

    public void finish(Database.BatchableContext bc){
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new List<String>{'systemadmin@output.com'});
        email.setSubject('Batch Process Completed');
        email.setPlainTextBody('The batch process has completed successfully.');
        emails.add(email);
        Messaging.sendEmail(emails);
    }
}