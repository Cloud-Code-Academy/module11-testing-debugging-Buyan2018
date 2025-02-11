@isTest
public with sharing class LeadTriggerHandlerTest {
    @TestSetup
    static void makeData(){

        Lead ldFirst = new Lead(LastName ='Fry', FirstName = 'Jay', Company = 'Fry And Sons');
        Lead ldSecond = new Lead(LastName = 'Fry', FirstName = 'John', Company = 'Fry And Sons');
        Lead ldThird = new Lead(LastName = 'Fry', FirstName = 'Ray', Company = 'Fry And Sons');

        Lead ldForth = new Lead(LastName = 'Smith', FirstName = 'John', Company = 'Smith and Sons');
        Lead ldFifth = new Lead(LastName = 'Smith', FirstName = 'Antony', Company = 'Smith and Sons');
        Lead ldSixth = new Lead(LastName = 'Smith', FirstName = 'Fred', Company = 'Smith and Sons');

        Lead ldSeventh = new Lead(LastName = 'Procter', FirstName = 'Jay',  Company = 'Procter and Gamble');
        Lead ldEighth = new Lead(LastName = 'Gamble', FirstName = 'Eugene', Company = 'Procter and Gamble');
        Lead ldNinth = new Lead(LastName = 'Gamble', FirstName = 'Tim', Company = 'Procter and Gamble');

        Lead ldTenth = new Lead(LastName = 'Smith', FirstName = 'John',  Company = 'Artists');
        Lead ldEleventh = new Lead(LastName = 'Smith', FirstName = 'Tim', Company = 'Artists');
        Lead ldTwentieth = new Lead(LastName = 'Smith', FirstName = 'Bob', Company = 'Artists');

        List<Lead> leadsToInsert = new List<Lead>{ldFirst, ldSecond, ldThird, ldForth, ldFifth, ldSixth, ldSeventh, ldEighth, ldNinth, ldTenth, ldEleventh, ldTwentieth};

        insert leadsToInsert;

        Account acc = new Account(Name = 'Account One');
        insert acc;
        Contact con = new Contact(LastName = 'Fry', Email = 'mark@example.com', AccountId = acc.Id);
        Contact conTwo = new Contact(LastName = 'Fry', Email = 'greg@example.com', AccountId = acc.Id);
        Contact conThree = new Contact(LastName = 'Fry', Email = 'greg@example.com', AccountId = acc.Id);
        List<Contact> consToInsert = new List<Contact>{con, conTwo, conThree};
        insert consToInsert;

    }
    @isTest
    public static void LeadTriggerHandler_insertWithTitleAndScore_success(){

        Lead ldFirst = new Lead(LastName ='Fry', FirstName = 'Jay', Company = 'Fry And Sons', Title = 'vp', LeadSource = 'Web', Email = 'jay@fryandsons.com.au');
        Lead ldSecond = new Lead(LastName = 'Fry', FirstName = 'John', Company = 'Fry And Sons', Title = 'v.p.', LeadSource = 'Web', Email = 'john@fryandsons.com.au');
        Lead ldThird = new Lead(LastName = 'Fry', FirstName = 'Ray', Company = 'Fry And Sons', Title = 'vice president', LeadSource = 'Web', Email = 'ray@fryandsons.com.au');

        Lead ldForth = new Lead(LastName = 'Smith', FirstName = 'John', Company = 'Smith and Sons', Title = 'mgr', Phone = '44555333');
        Lead ldFifth = new Lead(LastName = 'Smith', FirstName = 'Antony', Company = 'Smith and Sons', Title = 'manage', Phone = '656787689');
        Lead ldSixth = new Lead(LastName = 'Smith', FirstName = 'Fred', Company = 'Smith and Sons', Title = 'head of department', Phone = '9789878');

        Lead ldSeventh = new Lead(LastName = 'Procter', FirstName = 'Jay',  Company = 'Procter and Gamble', Title = 'exec', Industry = 'Technology');
        Lead ldEighth = new Lead(LastName = 'Gamble', FirstName = 'Eugene', Company = 'Procter and Gamble', Title = 'chief', Industry = 'Technology');
        Lead ldNinth = new Lead(LastName = 'Gamble', FirstName = 'Tim', Company = 'Procter and Gamble', Title = 'head', Industry = 'Technology');

        Lead ldTenth = new Lead(LastName = 'Smith', FirstName = 'John',  Company = 'Artists', Title = 'assist', LeadSource = 'Web', Email = 'jay@artist.com.au', Phone = '456789765', Industry = 'Technology');
        Lead ldEleventh = new Lead(LastName = 'Smith', FirstName = 'Tim', Company = 'Artists', Title = 'deputy', LeadSource = 'Web', Email = 'jay@artists.com.au', Phone = '3456789545', Industry = 'Technology');
        Lead ldTwentieth = new Lead(LastName = 'Smith', FirstName = 'Bob', Company = 'Artists', Title = 'jr', LeadSource = 'Web', Email = 'jay@artists.com.au', Phone = '45678976', Industry = 'Technology');
        
        List<Lead> leadsToInsert = new List<Lead>{ldFirst, ldSecond, ldThird, ldForth, ldFifth, ldSixth, ldSeventh, ldEighth, ldNinth, ldTenth, ldEleventh, ldTwentieth};

        Test.startTest();
        LeadTriggerHandler.handleTitleNormalization(leadsToInsert);
        LeadTriggerHandler.handleAutoLeadScoring(leadsToInsert);
        insert leadsToInsert;
        Test.stopTest();

        List<Lead> leadsWithScore3List = [SELECT Id FROM Lead WHERE Lead_Score__c =: 3];
        List<Lead> leadsWithScore5List = [SELECT Id FROM Lead WHERE Lead_Score__c =: 5];
        List<Lead> leadsWithScore10List = [SELECT Id FROM Lead WHERE Lead_Score__c =: 10];
        List<Lead> leadsWithScore18List = [SELECT Id FROM Lead WHERE Lead_Score__c =: 18];
        System.assertEquals(3, leadsWithScore3List.size(), 'Score for criteria one was assigned correctly');
        System.assertEquals(3, leadsWithScore5List.size(), 'Score for criteria two was assigned correctly');
        System.assertEquals(3, leadsWithScore10List.size(), 'Score for criteria three was assigned correctly');
        System.assertEquals(3, leadsWithScore18List.size(), 'Score for al criteria was assigned correctly');

        List<Lead> updatedLeadsVPList = [SELECT Id FROM Lead WHERE Title =: 'Vice President'];
        List<Lead> updatedLeadsManagerList = [SELECT Id FROM Lead WHERE Title =: 'Manager'];
        List<Lead> updatedLeadsExecutiveList = [SELECT Id FROM Lead WHERE Title =: 'Executive'];
        List<Lead> updatedLeadsAssistantList = [SELECT Id FROM Lead WHERE Title =: 'Assistant'];
        System.assertEquals(3, updatedLeadsVPList.size(), 'All VP Leads Titles were updated correctly');
        System.assertEquals(3, updatedLeadsManagerList.size(), 'All Manager Leads Titles were updated correctly');
        System.assertEquals(3, updatedLeadsExecutiveList.size(), 'All Executive Leads Titles were updated correctly');
        System.assertEquals(3, updatedLeadsAssistantList.size(), 'All Assistant Leads Titles were updated correctly');
    }
    @isTest
    public static void LeadTriggerHandler_update_success(){
        List<Lead> ldListToUpdate = new List<Lead>();
        List<Lead> ldVPList = [SELECT Title, LeadSource, Email, Phone, Industry FROM Lead WHERE Company =: 'Fry And Sons'];
        ldVPList[0].Title = 'vp'; ldVPList[0].LeadSource = 'Web'; ldVPList[0].Email = 'jay@fryandsons.com.au';
        ldVPList[1].Title = 'v.p.'; ldVPList[1].LeadSource = 'Web'; ldVPList[1].Email = 'john@fryandsons.com.au';
        ldVPList[2].Title = 'vice president'; ldVPList[2].LeadSource = 'Web'; ldVPList[2].Email = 'ray@fryandsons.com.au';
        ldListToUpdate.addAll(ldVPList);

        List<Lead> ldManagerList = [SELECT Title, LeadSource, Email, Phone, Industry FROM Lead WHERE Company =: 'Smith and Sons'];
        ldManagerList[0].Title = 'mgr'; ldManagerList[0].Phone = '44555333';
        ldManagerList[1].Title = 'manage'; ldManagerList[1].Phone = '656787689';
        ldManagerList[2].Title = 'head of department'; ldManagerList[2].Phone = '9789878';
        ldListToUpdate.addAll(ldManagerList);

        List<Lead> ldExecutiveList = [SELECT Title, LeadSource, Email, Phone, Industry FROM Lead WHERE Company =: 'Procter and Gamble'];
        ldExecutiveList[0].Title = 'exec'; ldExecutiveList[0].Industry = 'Technology';
        ldExecutiveList[1].Title = 'chief'; ldExecutiveList[1].Industry = 'Technology';
        ldExecutiveList[2].Title = 'head'; ldExecutiveList[2].Industry = 'Technology';
        ldListToUpdate.addAll(ldExecutiveList);

        List<Lead> ldAssistantList = [SELECT Title, LeadSource, Email, Phone, Industry FROM Lead WHERE Company =: 'Artists'];
        ldAssistantList[0].Title = 'assist'; ldAssistantList[0].LeadSource = 'Web'; ldAssistantList[0].Email = 'jay@artist.com.au'; ldAssistantList[0].Phone = '456789765'; ldAssistantList[0].Industry = 'Technology';
        ldAssistantList[1].Title = 'deputy'; ldAssistantList[1].LeadSource = 'Web'; ldAssistantList[1].Email = 'jay@artists.com.au'; ldAssistantList[1].Phone = '3456789545'; ldAssistantList[1].Industry = 'Technology';
        ldAssistantList[2].Title = 'jr'; ldAssistantList[2].LeadSource = 'Web'; ldAssistantList[2].Email = 'jay@artists.com.au'; ldAssistantList[2].Phone = '45678976'; ldAssistantList[2].Industry = 'Technology';
        ldListToUpdate.addAll(ldAssistantList);

        Test.startTest();
        LeadTriggerHandler.handleTitleNormalization(ldListToUpdate);
        LeadTriggerHandler.handleAutoLeadScoring(ldListToUpdate);
        update ldListToUpdate;
        Test.stopTest();

        List<Lead> leadsWithScore3List = [SELECT Id FROM Lead WHERE Lead_Score__c =: 3];
        List<Lead> leadsWithScore5List = [SELECT Id FROM Lead WHERE Lead_Score__c =: 5];
        List<Lead> leadsWithScore10List = [SELECT Id FROM Lead WHERE Lead_Score__c =: 10];
        List<Lead> leadsWithScore18List = [SELECT Id FROM Lead WHERE Lead_Score__c =: 18];
        System.assertEquals(3, leadsWithScore3List.size(), 'Score for criteria one was assigned correctly');
        System.assertEquals(3, leadsWithScore5List.size(), 'Score for criteria two was assigned correctly');
        System.assertEquals(3, leadsWithScore10List.size(), 'Score for criteria three was assigned correctly');
        System.assertEquals(3, leadsWithScore18List.size(), 'Score for al criteria was assigned correctly');

        List<Lead> updatedLeadsVPList = [SELECT Id FROM Lead WHERE Title =: 'Vice President'];
        List<Lead> updatedLeadsManagerList = [SELECT Id FROM Lead WHERE Title =: 'Manager'];
        List<Lead> updatedLeadsExecutiveList = [SELECT Id FROM Lead WHERE Title =: 'Executive'];
        List<Lead> updatedLeadsAssistantList = [SELECT Id FROM Lead WHERE Title =: 'Assistant'];
        System.assertEquals(3, updatedLeadsVPList.size(), 'All VP Leads Titles were updated correctly');
        System.assertEquals(3, updatedLeadsManagerList.size(), 'All Manager Leads Titles were updated correctly');
        System.assertEquals(3, updatedLeadsExecutiveList.size(), 'All Executive Leads Titles were updated correctly');
        System.assertEquals(3, updatedLeadsAssistantList.size(), 'All Assistant Leads Titles were updated correctly');
    }
    @isTest
    public static void LeadTriggerHandler_insertWithVPTitle_fail(){

        Lead ldFirst = new Lead(LastName ='Fry', FirstName = 'Jay', Company = 'Fry And Sons', Title = 'vop', LeadSource = 'Phone Inquiry', Email = 'jay@fryandsons.com.au');
        Lead ldSecond = new Lead(LastName = 'Fry', FirstName = 'John', Company = 'Fry And Sons', Title = 'v.op.', LeadSource = 'Phone Inquiry', Email = 'john@fryandsons.com.au');
        Lead ldThird = new Lead(LastName = 'Fry', FirstName = 'Ray', Company = 'Fry And Sons', Title = 'voce president', LeadSource = 'Phone Inquiry', Email = 'ray@fryandsons.com.au');

        Lead ldForth = new Lead(LastName = 'Smith', FirstName = 'John', Company = 'Smith and Sons', Title = 'mger', Phone = null);
        Lead ldFifth = new Lead(LastName = 'Smith', FirstName = 'Antony', Company = 'Smith and Sons', Title = 'menage', Phone = null);
        Lead ldSixth = new Lead(LastName = 'Smith', FirstName = 'Fred', Company = 'Smith and Sons', Title = 'heed of department', Phone = null);

        Lead ldSeventh = new Lead(LastName = 'Procter', FirstName = 'Jay',  Company = 'Procter and Gamble', Title = 'ixec', Industry = 'Agriculture');
        Lead ldEighth = new Lead(LastName = 'Gamble', FirstName = 'Eugene', Company = 'Procter and Gamble', Title = 'chiif', Industry = 'Agriculture');
        Lead ldNinth = new Lead(LastName = 'Gamble', FirstName = 'Tim', Company = 'Procter and Gamble', Title = 'hiad', Industry = 'Agriculture');

        Lead ldTenth = new Lead(LastName = 'Smith', FirstName = 'John',  Company = 'Artists', Title = 'asist', LeadSource = 'Phone Inquiry', Email = 'jay@artist.com.au', Phone = null, Industry = 'Agriculture');
        Lead ldEleventh = new Lead(LastName = 'Smith', FirstName = 'Tim', Company = 'Artists', Title = 'deputi', LeadSource = 'Phone Inquiry', Email = 'jay@artists.com.au', Phone = null, Industry = 'Agriculture');
        Lead ldTwentieth = new Lead(LastName = 'Smith', FirstName = 'Bob', Company = 'Artists', Title = 'jar', LeadSource = 'Phone Inquiry', Email = 'jay@artists.com.au', Phone = null, Industry = 'Agriculture');
        
        List<Lead> leadsToInsert = new List<Lead>{ldFirst, ldSecond, ldThird, ldForth, ldFifth, ldSixth, ldSeventh, ldEighth, ldNinth, ldTenth, ldEleventh, ldTwentieth};

        Test.startTest();
        LeadTriggerHandler.handleTitleNormalization(leadsToInsert);
        LeadTriggerHandler.handleAutoLeadScoring(leadsToInsert);
        insert leadsToInsert;
        Test.stopTest();

        List<Lead> leadsWith0ScoreList = [SELECT Id FROM Lead WHERE Lead_Score__c =: 0];
        System.assertEquals(24, leadsWith0ScoreList.size(), 'Score for criteria one was assigned correctly');

        List<Lead> updatedLeadsVPList = [SELECT Id FROM Lead WHERE Title =: 'Vice President'];
        List<Lead> updatedLeadsManagerList = [SELECT Id FROM Lead WHERE Title =: 'Manager'];
        List<Lead> updatedLeadsExecutiveList = [SELECT Id FROM Lead WHERE Title =: 'Executive'];
        List<Lead> updatedLeadsAssistantList = [SELECT Id FROM Lead WHERE Title =: 'Assistant'];
        System.assertEquals(0, updatedLeadsVPList.size(), 'All VP Leads Titles were updated correctly');
        System.assertEquals(0, updatedLeadsManagerList.size(), 'All Manager Leads Titles were updated correctly');
        System.assertEquals(0, updatedLeadsExecutiveList.size(), 'All Executive Leads Titles were updated correctly');
        System.assertEquals(0, updatedLeadsAssistantList.size(), 'All Assistant Leads Titles were updated correctly');
    }
 
    @isTest
    public static void handleLeadAutoConvert_insertLeadsWithSameEmail_Success(){

        Lead lead = new Lead(
            LastName = 'Fry',
            Email = 'mark@example.com',
            Company = 'Account One'
        );
        test.startTest();
        insert lead;
        test.stopTest();

        Lead insertedLead = [SELECT Id, IsConverted FROM Lead WHERE Email =: 'mark@example.com'];
        System.assertEquals(true, insertedLead.IsConverted, 'Created Lead converted automatically');
    }

    @isTest
    public static void handleLeadAutoConvert_updateLeadsWithSameEmail_Success(){
        Lead lead = [SELECT Id, Email FROM Lead WHERE LastName =: 'Fry' AND FirstName =: 'Jay' LIMIT 1];
        lead.Email = 'mark@example.com';

        test.startTest();
        update lead;
        test.stopTest();

        Lead updatedLead = [SELECT Id, IsConverted FROM Lead WHERE Id =: lead.Id];
        System.assertEquals(true, updatedLead.IsConverted, 'Lead was updated after Email Update');

    }

    @isTest
    public static void handleLeadAutoConvert_updateLeadsWithSameSeveralContacts_Fail(){
        Lead lead = [SELECT Id, Email FROM Lead WHERE LastName =: 'Fry' AND FirstName =: 'Jay' LIMIT 1];
        lead.Email = 'greg@example.com';

        test.startTest();
        update lead;
        test.stopTest();

        Lead updatedLead = [SELECT Id, IsConverted FROM Lead WHERE Id =: lead.Id];
        System.assertEquals(false, updatedLead.IsConverted, 'Lead was updated after Email Update');
    }
}