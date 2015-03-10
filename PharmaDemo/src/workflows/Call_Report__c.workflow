<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Appointment</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Appointment</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Appointment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CallReport</fullName>
        <field>RecordTypeId</field>
        <lookupValue>CallReport</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Call Report</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Lock_Call</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Locked_Call_Report</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Lock Call</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Meeting</fullName>
        <field>Type__c</field>
        <literalValue>Meeting</literalValue>
        <name>Meeting</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MeetingAttendees</fullName>
        <field>Type__c</field>
        <literalValue>1:1</literalValue>
        <name>Meeting Attendees</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Name_on_Call_Report</fullName>
        <field>Name</field>
        <formula>TEXT( DAY(CallDate__c)) &amp;&quot;/&quot;&amp;TEXT( MONTH(CallDate__c)) &amp;&quot;/&quot;&amp;TEXT( YEAR(CallDate__c))  &amp;&quot; - &quot; &amp; Location__r.Name</formula>
        <name>Update Name on Call Report</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Appointment</fullName>
        <actions>
            <name>Appointment</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Call_Report__c.Type__c</field>
            <operation>equals</operation>
            <value>Appointment</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Call Report</fullName>
        <actions>
            <name>CallReport</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Call_Report__c.Type__c</field>
            <operation>equals</operation>
            <value>Meeting,1:1</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Name on Call Report</fullName>
        <actions>
            <name>Update_Name_on_Call_Report</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
