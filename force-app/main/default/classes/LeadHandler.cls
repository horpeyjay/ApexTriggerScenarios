public with sharing class LeadHandler {
    //Assignment 2 Whenever a Lead record is updated, set the Lead Status to “Working-Contacted”
    public static void leadStatusUdpate(List<Lead> leadList, Map<Id, Lead> oldLeadMap){
        if(!leadList.isEmpty()){
            for(Lead lead : leadList){
                Lead oldLead = new Lead();
                if(oldLeadMap != null){
                    oldLead = oldLeadMap.get(lead.Id);
                    if(lead.Status != oldLead.Status && oldlead.Status != 'Working-Contacted'){
                        lead.Status = 'Working-Contacted';
                    }
                    if(lead.Industry != oldLead.Industry){
                        // Whenever a Lead is updated and Industry is “Healthcare”, set Lead Source, SIC Code and Primary.
                        if(lead.Industry == 'Healthcare'){
                            lead.LeadSource = 'Web';
                            lead.SicCode__c = '7839';
                            lead.Primary__c = 'Yes';
                        }
                    }

                    if(oldLead.CreatedDate < Date.today() - 8){
                        lead.addError('You can not edit a Lead dated 8 days ago');
                    }
                }else{
                    //Assignment 25: Whenever Lead is created with LeadSource as “Web” then give rating as “Cold” otherwise “Hot”.
                    if(lead.LeadSource == 'Web'){
                        lead.Rating = 'Cold';
                    }else{
                        lead.Rating = 'Hot';
                    }
                }
                
            }
        }
    }

    public static void createTaskOnLead(List<Lead> leadList){
        // Assignment 6: When a Lead record is created, create a Task for the Lead Owner to follow up with the Customer.
        List<Task> taskToCreate = new List<Task>();
        if(!leadList.isEmpty()){
            for(Lead l : leadList){
                Task t = new Task();
                t.Subject = 'Follow-Up with Customer';
                t.WhoId = l.Id;
                t.OwnerId = l.OwnerId;
                t.Priority = 'Medium';
                t.ActivityDate = Date.today() + 5;
                taskToCreate.add(t);
            }
        }

        if(!taskToCreate.isEmpty()){
            insert taskToCreate;
        }
    }

    public static void doNotDelete(List<Lead> leadList){
        //Assignment 12: Do not allow Lead deletion if the status is “Working Contacted”
        if(!leadList.isEmpty()){
            for(Lead l : leadList){
                if(l.Status == 'Working-Contacted'){
                    l.addError('You cannot delete a Working - Contacted Lead');
                }
            }
        }
    }
}