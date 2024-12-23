public with sharing class TaskHandler {
    //1. Whenever a Task is created, set the Priority to “High”.
    public static void taskPriorityHigh(List<Task> taskList){
        if(!taskList.isEmpty()){
            for(Task t : taskList){
                t.Priority = 'High';
            }
        }
    }

    public static void countTask(List<Task> taskList){
        Set<Id> conIds = new Set<Id>();
        if(!taskList.isEmpty()){
            for(Task t : taskList){
                if(t.WhoId != null && t.WhoId.getSObjectType() == Contact.sObjectType){
                    conIds.add(t.WhoId);
                }
            }
        }
        Map<Id, Integer> conIdToTaskCount = new Map<Id, Integer>();
        if(!conIds.isEmpty()){
            List<Task> contactTaskList = [Select WhoId from Task where WhoId in : conIds];

            for(Task t : contactTaskList){
                if(conIdToTaskCount.containsKey(t.WhoId)){
                    conIdToTaskCount.put(t.WhoId, conIdToTaskCount.get(t.WhoId) + 1);
                }else{
                    conIdToTaskCount.put(t.WhoId, 1);
                }
            }
        }

        if(!taskList.isEmpty()){
            for(Task t : taskList){
                if(t.WhoId != null){
                    if(conIdToTaskCount.containsKey(t.WhoId)){
                        conIdToTaskCount.put(t.WhoId, conIdToTaskCount.get(t.WhoId) + 1);
                    }else{
                        conIdToTaskCount.put(t.WhoId, 1);
                    }
                }
            }
        }
        List<Contact> consToInsert = new List<Contact>();
        if(!conIdToTaskCount.isEmpty()){
            List<Contact> contactList = [Select Id, Number_of_Tasks__c From Contact Where Id in : conIdToTaskCount.keySet()];
            for(Contact c : contactList){
                if(conIdToTaskCount.containsKey(c.Id)){
                    c.Number_of_Tasks__c = conIdToTaskCount.get(c.Id);
                    consToInsert.add(c);
                }
            }
        }

        if(!consToInsert.isEmpty()){
            update consToInsert;
        }
    }
}