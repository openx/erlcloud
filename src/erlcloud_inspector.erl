-module(erlcloud_inspector).
-author('zfox@alertlogic.com').

-include("erlcloud.hrl").
-include("erlcloud_aws.hrl").


%%% Library initialization.
-export([configure/2, configure/3, configure/4, new/2, new/3, new/4, inspector_result_fun/1]).


%%% Inspector API
-export([add_attributes_to_findings/2, add_attributes_to_findings/3,
         attach_assessment_and_rules_package/2, attach_assessment_and_rules_package/3,
         create_application/2, create_application/3,
         create_assessment/3, create_assessment/4, create_assessment/5,
         create_resource_group/1, create_resource_group/2,
         delete_application/1, delete_application/2,
         delete_assessment/1, delete_assessment/2,
         describe_cross_account_access_role/0, describe_cross_account_access_role/1,
         delete_run/1, delete_run/2,
         describe_application/1, describe_application/2,
         describe_assessment/1, describe_assessment/2,
         describe_finding/1, describe_finding/2,
         describe_resource_group/1, describe_resource_group/2,
         describe_rules_package/1, describe_rules_package/2,
         describe_run/1, describe_run/2,
         detach_assessment_and_rules_package/2, detach_assessment_and_rules_package/3,
         get_assessment_telemetry/1, get_assessment_telemetry/2,
         list_applications/0, list_applications/1, list_applications/2,
         list_assessment_agents/1, list_assessment_agents/2, list_assessment_agents/3,
         list_assessments/0, list_assessments/1, list_assessments/2,
         list_attached_assessments/1, list_attached_assessments/2, list_attached_assessments/3,
         list_attached_rules_packages/1, list_attached_rules_packages/2, list_attached_rules_packages/3,
         list_findings/0, list_findings/1, list_findings/2,
         list_rules_packages/0, list_rules_packages/1, list_rules_packages/2,
         list_runs/0, list_runs/1, list_runs/2,
         list_tags_for_resource/1, list_tags_for_resource/2, list_tags_for_resource/3,
         localize_text/1, localize_text/2, localize_text/3,
         preview_agents_for_resource_group/1, preview_agents_for_resource_group/2, preview_agents_for_resource_group/3,
         register_cross_account_access_role/1, register_cross_account_access_role/2, register_cross_account_access_role/3,
         remove_attributes_from_findings/2, remove_attributes_from_findings/3,
         run_assessment/2, run_assessment/3,
         set_tags_for_resource/2, set_tags_for_resource/3,
         start_data_collection/1, start_data_collection/2,
         stop_data_collection/1, stop_data_collection/2,
         update_application/3, update_application/4,
         update_assessment/3, update_assessment/4]).


%%%------------------------------------------------------------------------------
%%% Shared types
%%%------------------------------------------------------------------------------
-type inspector_opts() :: list().

-type return_val() :: {ok, proplists:proplist()} | {error, term()}.

-export_type([return_val/0]).

%%%------------------------------------------------------------------------------
%%% Library initialization.
%%%------------------------------------------------------------------------------

-spec new(string(), string()) -> aws_config().

new(AccessKeyID, SecretAccessKey) ->
    #aws_config{
       access_key_id=AccessKeyID,
       secret_access_key=SecretAccessKey
      }.

-spec new(string(), string(), string()) -> aws_config().

new(AccessKeyID, SecretAccessKey, Host) ->
    #aws_config{
       access_key_id=AccessKeyID,
       secret_access_key=SecretAccessKey,
       inspector_host=Host
      }.

-spec new(string(), string(), string(), non_neg_integer()) -> aws_config().

new(AccessKeyID, SecretAccessKey, Host, Port) ->
    #aws_config{
       access_key_id=AccessKeyID,
       secret_access_key=SecretAccessKey,
       inspector_host=Host,
       inspector_port=Port
      }.

-spec configure(string(), string()) -> ok.

configure(AccessKeyID, SecretAccessKey) ->
    put(aws_config, new(AccessKeyID, SecretAccessKey)),
    ok.

-spec configure(string(), string(), string()) -> ok.

configure(AccessKeyID, SecretAccessKey, Host) ->
    put(aws_config, new(AccessKeyID, SecretAccessKey, Host)),
    ok.

-spec configure(string(), string(), string(), non_neg_integer()) -> ok.

configure(AccessKeyID, SecretAccessKey, Host, Port) ->
    put(aws_config, new(AccessKeyID, SecretAccessKey, Host, Port)),
    ok.

default_config() ->
    erlcloud_aws:default_config().


-spec inspector_result_fun/1 ::
          (Request :: aws_request()) -> aws_request().
inspector_result_fun(#aws_request{response_type = ok} = Request) ->
    Request;
inspector_result_fun(#aws_request{response_type = error,
                                  error_type = aws,
                                  response_status = Status} = Request) when Status >= 500 ->
    Request#aws_request{should_retry = true};
inspector_result_fun(#aws_request{response_type = error, error_type = aws} = Request) ->
    Request#aws_request{should_retry = false}.

%%%------------------------------------------------------------------------------
%%% Inspector API Functions
%%%------------------------------------------------------------------------------


%%%------------------------------------------------------------------------------
%%% AddAttributesToFindings
%%
%% http://docs.aws.amazon.com/inspector/latest/APIReference/API_AddAttributesToFindings.html
%%%------------------------------------------------------------------------------
-type attribute() :: proplists:proplist().

-spec add_attributes_to_findings/2 ::
          (Attributes :: [attribute()],
           FindingArns :: [string()]) ->
          return_val().
add_attributes_to_findings(Attributes, FindingArns) ->
    add_attributes_to_findings(Attributes, FindingArns, default_config()).


-spec add_attributes_to_findings/3 ::
          (Attributes :: [attribute()],
           FindingArns :: [string()],
           Config :: aws_config()) ->
          return_val().
add_attributes_to_findings(Attributes, FindingArns, Config) ->
    Json = [{<<"attributes">>, Attributes},
            {<<"findingArns">>, [to_binary(A) || A <- FindingArns]}],
    inspector_request(Config, "InspectorService.AddAttributesToFindings", Json).


%%%------------------------------------------------------------------------------
%%% AttachAssessmentAndRulesPackage
%%
%% http://docs.aws.amazon.com/inspector/latest/APIReference/API_AttachAssessmentAndRulesPackage.html
%%%------------------------------------------------------------------------------

-spec attach_assessment_and_rules_package/2 ::
          (AssessmentArn :: string(),
           RulesPackageArn :: string()) ->
          return_val().
attach_assessment_and_rules_package(AssessmentArn, RulesPackageArn) ->
    attach_assessment_and_rules_package(AssessmentArn, RulesPackageArn, default_config()).


-spec attach_assessment_and_rules_package/3 ::
          (AssessmentArn :: string(),
           RulesPackageArn :: string(),
           Config :: aws_config()) ->
          return_val().
attach_assessment_and_rules_package(AssessmentArn, RulesPackageArn, Config) ->
    Json = [{<<"assessmentArn">>, to_binary(AssessmentArn)},
            {<<"rulesPackageArn">>, to_binary(RulesPackageArn)}],
    inspector_request(Config, "InspectorService.AttachAssessmentAndRulesPackage", Json).


%%%------------------------------------------------------------------------------
%%% CreateApplication
%%
%% http://docs.aws.amazon.com/inspector/latest/APIReference/API_CreateApplication.html
%%%------------------------------------------------------------------------------

-spec create_application/2 ::
          (ApplicationName :: string(),
           ResourceGroupArn :: string()) ->
          return_val().
create_application(ApplicationName, ResourceGroupArn) ->
    create_application(ApplicationName, ResourceGroupArn, default_config()).


-spec create_application/3 ::
          (ApplicationName :: string(),
           ResourceGroupArn :: string(),
           Config :: aws_config()) ->
          return_val().
create_application(ApplicationName, ResourceGroupArn, Config) ->
    Json = [{<<"applicationName">>, to_binary(ApplicationName)},
            {<<"resourceGroupArn">>, to_binary(ResourceGroupArn)}],
    inspector_request(Config, "InspectorService.CreateApplication", Json).


%%%------------------------------------------------------------------------------
%%% CreateAssessment
%%
%% http://docs.aws.amazon.com/inspector/latest/APIReference/API_CreateAssessment.html
%%%------------------------------------------------------------------------------

-spec create_assessment/3 ::
          (ApplicationArn :: string(),
           AssessmentName :: string(),
           DurationInSeconds :: integer()) ->
          return_val().
create_assessment(ApplicationArn, AssessmentName, DurationInSeconds) ->
    create_assessment(ApplicationArn, AssessmentName, DurationInSeconds, []).


-spec create_assessment/4 ::
          (ApplicationArn :: string(),
           AssessmentName :: string(),
           DurationInSeconds :: integer(),
           Options :: inspector_opts()) ->
          return_val().
create_assessment(ApplicationArn, AssessmentName, DurationInSeconds, Options) ->
    create_assessment(ApplicationArn, AssessmentName, DurationInSeconds, Options, default_config()).


-spec create_assessment/5 ::
          (ApplicationArn :: string(),
           AssessmentName :: string(),
           DurationInSeconds :: integer(),
           Options :: inspector_opts(),
           Config :: aws_config()) ->
          return_val().
create_assessment(ApplicationArn, AssessmentName, DurationInSeconds, Options, Config) ->
    OptJson = dynamize_options(Options),
    Json = [{<<"applicationArn">>, to_binary(ApplicationArn)},
            {<<"assessmentName">>, to_binary(AssessmentName)},
            {<<"durationInSeconds">>, DurationInSeconds}|OptJson],
    inspector_request(Config, "InspectorService.CreateAssessment", Json).


%%%------------------------------------------------------------------------------
%%% CreateResourceGroup
%%
%% http://docs.aws.amazon.com/inspector/latest/APIReference/API_CreateResourceGroup.html
%%%------------------------------------------------------------------------------

-spec create_resource_group/1 ::
          (ResourceGroupTags :: term()) ->
          return_val().
create_resource_group(ResourceGroupTags) ->
    create_resource_group(ResourceGroupTags, default_config()).


-spec create_resource_group/2 ::
          (ResourceGroupTags :: term(),
           Config :: aws_config()) ->
          return_val().
create_resource_group(ResourceGroupTags, Config) ->
    Json = [{<<"resourceGroupTags">>, jsx:encode(ResourceGroupTags)}],
    inspector_request(Config, "InspectorService.CreateResourceGroup", Json).


%%%------------------------------------------------------------------------------
%%% DeleteApplication
%%
%% http://docs.aws.amazon.com/inspector/latest/APIReference/API_DeleteApplication.html
%%%------------------------------------------------------------------------------

-spec delete_application/1 ::
          (ApplicationArn :: string()) ->
          return_val().
delete_application(ApplicationArn) ->
    delete_application(ApplicationArn, default_config()).


-spec delete_application/2 ::
          (ApplicationArn :: string(),
           Config :: aws_config()) ->
          return_val().
delete_application(ApplicationArn, Config) ->
    Json = [{<<"applicationArn">>, to_binary(ApplicationArn)}],
    inspector_request(Config, "InspectorService.DeleteApplication", Json).


%%%------------------------------------------------------------------------------
%%% DeleteAssessment
%%
%% http://docs.aws.amazon.com/inspector/latest/APIReference/API_DeleteAssessment.html
%%%------------------------------------------------------------------------------

-spec delete_assessment/1 ::
          (AssessmentArn :: string()) ->
          return_val().
delete_assessment(AssessmentArn) ->
    delete_assessment(AssessmentArn, default_config()).


-spec delete_assessment/2 ::
          (AssessmentArn :: string(),
           Config :: aws_config()) ->
          return_val().
delete_assessment(AssessmentArn, Config) ->
    Json = [{<<"assessmentArn">>, to_binary(AssessmentArn)}],
    inspector_request(Config, "InspectorService.DeleteAssessment", Json).


%%%------------------------------------------------------------------------------
%%% DeleteRun
%%
%% http://docs.aws.amazon.com/inspector/latest/APIReference/API_DeleteRun.html
%%%------------------------------------------------------------------------------

-spec delete_run/1 ::
          (RunArn :: string()) ->
          return_val().
delete_run(RunArn) ->
    delete_run(RunArn, default_config()).


-spec delete_run/2 ::
          (RunArn :: string(),
           Config :: aws_config()) ->
          return_val().
delete_run(RunArn, Config) ->
    Json = [{<<"runArn">>, to_binary(RunArn)}],
    inspector_request(Config, "InspectorService.DeleteRun", Json).


%%%------------------------------------------------------------------------------
%%% DescribeApplication
%%
%% http://docs.aws.amazon.com/inspector/latest/APIReference/API_DescribeApplication.html
%%%------------------------------------------------------------------------------

-spec describe_application/1 ::
          (ApplicationArn :: string()) ->
          return_val().
describe_application(ApplicationArn) ->
    describe_application(ApplicationArn, default_config()).


-spec describe_application/2 ::
          (ApplicationArn :: string(),
           Config :: aws_config()) ->
          return_val().
describe_application(ApplicationArn, Config) ->
    Json = [{<<"applicationArn">>, to_binary(ApplicationArn)}],
    inspector_request(Config, "InspectorService.DescribeApplication", Json).


%%%------------------------------------------------------------------------------
%%% DescribeAssessment
%%
%% http://docs.aws.amazon.com/inspector/latest/APIReference/API_DescribeAssessment.html
%%%------------------------------------------------------------------------------

-spec describe_assessment/1 ::
          (AssessmentArn :: string()) ->
          return_val().
describe_assessment(AssessmentArn) ->
    describe_assessment(AssessmentArn, default_config()).


-spec describe_assessment/2 ::
          (AssessmentArn :: string(),
           Config :: aws_config()) ->
          return_val().
describe_assessment(AssessmentArn, Config) ->
    Json = [{<<"assessmentArn">>, to_binary(AssessmentArn)}],
    inspector_request(Config, "InspectorService.DescribeAssessment", Json).


%%%------------------------------------------------------------------------------
%%% DescribeCrossAccountAccessRole
%%
%% http://docs.aws.amazon.com/inspector/latest/APIReference/API_DescribeCrossAccountAccessRole.html
%%%------------------------------------------------------------------------------

-spec describe_cross_account_access_role/0 ::
          () ->
          return_val().
describe_cross_account_access_role() ->
    describe_cross_account_access_role(default_config()).


-spec describe_cross_account_access_role/1 ::
          (Config :: aws_config()) ->
          return_val().
describe_cross_account_access_role(Config) ->
    inspector_request(Config, "InspectorService.DescribeCrossAccountAccessRole", <<>>).


%%%------------------------------------------------------------------------------
%%% DescribeFinding
%%
%%http://docs.aws.amazon.com/inspector/latest/APIReference/API_DescribeFinding.html
%%%------------------------------------------------------------------------------

-spec describe_finding/1 ::
          (FindingArn :: string()) ->
          return_val().
describe_finding(FindingArn) ->
    describe_finding(FindingArn, default_config()).


-spec describe_finding/2 ::
          (FindingArn :: string(),
           Config :: aws_config()) ->
          return_val().
describe_finding(FindingArn, Config) ->
    Json = [{<<"findingArn">>, to_binary(FindingArn)}],
    inspector_request(Config, "InspectorService.DescribeFinding", Json).


%%%------------------------------------------------------------------------------
%%% DescribeResourceGroup
%%
%% http://docs.aws.amazon.com/inspector/latest/APIReference/API_DescribeResourceGroup.html
%%%------------------------------------------------------------------------------

-spec describe_resource_group/1 ::
          (ResourceGroupArn :: string()) ->
          return_val().
describe_resource_group(ResourceGroupArn) ->
    describe_resource_group(ResourceGroupArn, default_config()).


-spec describe_resource_group/2 ::
          (ResourceGroupArn :: string(),
           Config :: aws_config()) ->
          return_val().
describe_resource_group(ResourceGroupArn, Config) ->
    Json = [{<<"resourceGroupArn">>, to_binary(ResourceGroupArn)}],
    inspector_request(Config, "InspectorService.DescribeResourceGroup", Json).


%%%------------------------------------------------------------------------------
%%% DescribeRulesPackage
%%
%% http://docs.aws.amazon.com/inspector/latest/APIReference/API_DescribeRulesPackage.html
%%%------------------------------------------------------------------------------

-spec describe_rules_package/1 ::
          (RulesPackageArn :: string()) ->
          return_val().
describe_rules_package(RulesPackageArn) ->
    describe_rules_package(RulesPackageArn, default_config()).


-spec describe_rules_package/2 ::
          (RulesPackageArn :: string(),
           Config :: aws_config()) ->
          return_val().
describe_rules_package(RulesPackageArn, Config) ->
    Json = [{<<"rulesPackageArn">>, to_binary(RulesPackageArn)}],
    inspector_request(Config, "InspectorService.DescribeRulesPackage", Json).


%%%------------------------------------------------------------------------------
%%% DescribeRun
%%
%% http://docs.aws.amazon.com/inspector/latest/APIReference/API_DescribeRun.html
%%%------------------------------------------------------------------------------

-spec describe_run/1 ::
          (RunArn :: string()) ->
          return_val().
describe_run(RunArn) ->
    describe_run(RunArn, default_config()).


-spec describe_run/2 ::
          (RunArn :: string(),
           Config :: aws_config()) ->
          return_val().
describe_run(RunArn, Config) ->
    Json = [{<<"runArn">>, to_binary(RunArn)}],
    inspector_request(Config, "InspectorService.DescribeRun", Json).


%%%------------------------------------------------------------------------------
%%% DetachAssessmentAndRulesPackage
%%
%% http://docs.aws.amazon.com/inspector/latest/APIReference/API_DetachAssessmentAndRulesPackage.html
%%%------------------------------------------------------------------------------

-spec detach_assessment_and_rules_package/2 ::
          (AssessmentArn :: string(),
           RulesPackageArn :: string()) ->
          return_val().
detach_assessment_and_rules_package(AssessmentArn, RulesPackageArn) ->
    detach_assessment_and_rules_package(AssessmentArn, RulesPackageArn, default_config()).


-spec detach_assessment_and_rules_package/3 ::
          (AssessmentArn :: string(),
           RulesPackageArn :: string(),
           Config :: aws_config()) ->
          return_val().
detach_assessment_and_rules_package(AssessmentArn, RulesPackageArn, Config) ->
    Json = [{<<"assessmentArn">>, to_binary(AssessmentArn)},
            {<<"rulesPackageArn">>, to_binary(RulesPackageArn)}],
    inspector_request(Config, "InspectorService.DetachAssessmentAndRulesPackage", Json).


%%%------------------------------------------------------------------------------
%%% GetAssessmentTelemetry
%%
%% http://docs.aws.amazon.com/inspector/latest/APIReference/API_GetAssessmentTelemetry.html
%%%------------------------------------------------------------------------------

-spec get_assessment_telemetry/1 ::
          (AssessmentArn :: string()) ->
          return_val().
get_assessment_telemetry(AssessmentArn) ->
    get_assessment_telemetry(AssessmentArn, default_config()).


-spec get_assessment_telemetry/2 ::
          (AssessmentArn :: string(),
           Config :: aws_config()) ->
          return_val().
get_assessment_telemetry(AssessmentArn, Config) ->
    Json = [{<<"assessmentArn">>, to_binary(AssessmentArn)}],
    inspector_request(Config, "InspectorService.GetAssessmentTelemetry", Json).


%%%------------------------------------------------------------------------------
%%% ListApplications
%%
%% http://docs.aws.amazon.com/inspector/latest/APIReference/API_ListApplications.html
%%%------------------------------------------------------------------------------

-spec list_applications/0 ::
          () ->
          return_val().
list_applications() ->
    list_applications([]).


-spec list_applications/1 ::
          (Options :: inspector_opts()) ->
          return_val().
list_applications(Options) ->
    list_applications(Options, default_config()).


-spec list_applications/2 ::
          (Options :: inspector_opts(),
           Config :: aws_config()) ->
          return_val().
list_applications(Options, Config) ->
    OptJson = dynamize_options(Options),
    inspector_request(Config, "InspectorService.ListApplications", OptJson).


%%%------------------------------------------------------------------------------
%%% ListAssessmentAgents
%%
%% http://docs.aws.amazon.com/inspector/latest/APIReference/API_ListAssessmentAgents.html
%%%------------------------------------------------------------------------------

-spec list_assessment_agents/1 ::
          (AssessmentArn :: string()) ->
          return_val().
list_assessment_agents(AssessmentArn) ->
    list_assessment_agents(AssessmentArn, []).


-spec list_assessment_agents/2 ::
          (AssessmentArn :: string(),
           Options :: inspector_opts()) ->
          return_val().
list_assessment_agents(AssessmentArn, Options) ->
    list_assessment_agents(AssessmentArn, Options, default_config()).


-spec list_assessment_agents/3 ::
          (AssessmentArn :: string(),
           Options :: inspector_opts(),
           Config :: aws_config()) ->
          return_val().
list_assessment_agents(AssessmentArn, Options, Config) ->
    OptJson = dynamize_options(Options),
    Json = [{assessmentArn, to_binary(AssessmentArn)}|OptJson],
    inspector_request(Config, "InspectorService.ListAssessmentAgents", Json).


%%%------------------------------------------------------------------------------
%%% ListAssessments
%%
%% http://docs.aws.amazon.com/inspector/latest/APIReference/API_ListAssessments.html
%%%------------------------------------------------------------------------------

-spec list_assessments/0 ::
          () ->
          return_val().
list_assessments() ->
    list_assessments([]).


-spec list_assessments/1 ::
          (Options :: inspector_opts()) ->
          return_val().
list_assessments(Options) ->
    list_assessments(Options, default_config()).


-spec list_assessments/2 ::
          (Options :: inspector_opts(),
           Config :: aws_config()) ->
          return_val().
list_assessments(Options, Config) ->
    OptJson = dynamize_options(Options),
    inspector_request(Config, "InspectorService.ListAssessments", OptJson).


%%%------------------------------------------------------------------------------
%%% ListAttachedAssessments
%%
%% http://docs.aws.amazon.com/inspector/latest/APIReference/API_ListAttachedAssessments.html
%%%------------------------------------------------------------------------------

-spec list_attached_assessments/1 ::
          (RulesPackageArn :: string()) ->
          return_val().
list_attached_assessments(RulesPackageArn) ->
    list_attached_assessments(RulesPackageArn, []).


-spec list_attached_assessments/2 ::
          (RulesPackageArn :: string(),
           Options :: inspector_opts()) ->
          return_val().
list_attached_assessments(RulesPackageArn, Options) ->
    list_attached_assessments(RulesPackageArn, Options, default_config()).


-spec list_attached_assessments/3 ::
          (RulesPackageArn :: string(),
           Options :: inspector_opts(),
           Config :: aws_config()) ->
          return_val().
list_attached_assessments(RulesPackageArn, Options, Config) ->
    OptJson = dynamize_options(Options),
    Json = [{<<"rulesPackageArn">>, to_binary(RulesPackageArn)}|OptJson],
    inspector_request(Config, "InspectorService.ListAttachedAssessments", Json).


%%%------------------------------------------------------------------------------
%%% ListAttachedRulesPackages
%%
%% http://docs.aws.amazon.com/inspector/latest/APIReference/API_ListAttachedRulesPackages.html
%%%------------------------------------------------------------------------------

-spec list_attached_rules_packages/1 ::
          (AssessmentArn :: string()) ->
          return_val().
list_attached_rules_packages(AssessmentArn) ->
    list_attached_rules_packages(AssessmentArn, []).


-spec list_attached_rules_packages/2 ::
          (AssessmentArn :: string(),
           Options :: inspector_opts()) ->
          return_val().
list_attached_rules_packages(AssessmentArn, Options) ->
    list_attached_rules_packages(AssessmentArn, Options, default_config()).


-spec list_attached_rules_packages/3 ::
          (AssessmentArn :: string(),
           Options :: inspector_opts(),
           Config :: aws_config()) ->
          return_val().
list_attached_rules_packages(AssessmentArn, Options, Config) ->
    OptJson = dynamize_options(Options),
    Json = [{<<"assessmentArn">>, to_binary(AssessmentArn)}|OptJson],
    inspector_request(Config, "InspectorService.ListAttachedRulesPackages", Json).


%%%------------------------------------------------------------------------------
%%% ListFindings
%%
%% http://docs.aws.amazon.com/inspector/latest/APIReference/API_ListFindings.html
%%%------------------------------------------------------------------------------

-spec list_findings/0 ::
          () ->
          return_val().
list_findings() ->
    list_findings([]).


-spec list_findings/1 ::
          (Options :: inspector_opts()) ->
          return_val().
list_findings(Options) ->
    list_findings(Options, default_config()).


-spec list_findings/2 ::
          (Options :: inspector_opts(), 
           Config :: aws_config()) ->
          return_val().
list_findings(Options, Config) ->
    OptJson = dynamize_options(Options),
    inspector_request(Config, "InspectorService.ListFindings", OptJson).


%%%------------------------------------------------------------------------------
%%% ListRulesPackages
%%
%% http://docs.aws.amazon.com/inspector/latest/APIReference/API_ListRulesPackages.html
%%%------------------------------------------------------------------------------

-spec list_rules_packages/0 ::
          () ->
          return_val().
list_rules_packages() ->
    list_rules_packages([]).


-spec list_rules_packages/1 ::
          (Options :: inspector_opts()) ->
          return_val().
list_rules_packages(Options) ->
    list_rules_packages(Options, default_config()).


-spec list_rules_packages/2 ::
          (Options :: inspector_opts(), 
           Config :: aws_config()) ->
          return_val().
list_rules_packages(Options, Config) ->
    OptJson = dynamize_options(Options),
    inspector_request(Config, "InspectorService.ListRulesPackages", OptJson).


%%%------------------------------------------------------------------------------
%%% ListRuns
%%
%% http://docs.aws.amazon.com/inspector/latest/APIReference/API_ListRuns.html
%%%------------------------------------------------------------------------------

-spec list_runs/0 ::
          () ->
          return_val().
list_runs() ->
    list_runs([]).


-spec list_runs/1 ::
          (Options :: inspector_opts()) ->
          return_val().
list_runs(Options) ->
    list_runs(Options, default_config()).


-spec list_runs/2 ::
          (Options :: inspector_opts(), 
           Config :: aws_config()) ->
          return_val().
list_runs(Options, Config) ->
    OptJson = dynamize_options(Options),
    inspector_request(Config, "InspectorService.ListRuns", OptJson).


%%%------------------------------------------------------------------------------
%%% ListTagsForResource
%%
%% http://docs.aws.amazon.com/inspector/latest/APIReference/API_ListTagsForResource.html
%%%------------------------------------------------------------------------------

-spec list_tags_for_resource/1 ::
          (ResourceArn :: string()) ->
          return_val().
list_tags_for_resource(ResourceArn) ->
    list_tags_for_resource(ResourceArn, []).


-spec list_tags_for_resource/2 ::
          (ResourceArn :: string(),
           Options :: inspector_opts()) ->
          return_val().
list_tags_for_resource(ResourceArn, Options) ->
    list_tags_for_resource(ResourceArn, Options, default_config()).


-spec list_tags_for_resource/3 ::
          (ResourceArn :: string(),
           Options :: inspector_opts(),
           Config :: aws_config()) ->
          return_val().
list_tags_for_resource(ResourceArn, Options, Config) ->
    OptJson = dynamize_options(Options),
    Json = [{<<"resourceArn">>, to_binary(ResourceArn)}|OptJson],
    inspector_request(Config, "InspectorService.ListTagsForResource", Json).


%%%------------------------------------------------------------------------------
%%% LocalizeText
%%
%% http://docs.aws.amazon.com/inspector/latest/APIReference/API_LocalizeText.html
%% {ok, Res1} = erlcloud_inspector:list_findings().
%% [FindingArn|_] = FindingARNList = proplists:get_value(<<"findingArnList">>, Res1).
%% {ok, Res2} = erlcloud_inspector:describe_finding(FindingArn).
%% Finding = proplists:get_value(<<"finding">>, Res2).
%% Description = proplists:get_value(<<"description">>, Finding).
%% {ok, Res3} = erlcloud_inspector:localize_text(Description).
%% [DescriptionText] = proplists:get_value(<<"results">>, Res3).
%%
%%%------------------------------------------------------------------------------
-type localized_text() :: term().

-spec localize_text/1 ::
          (LocalizedTexts :: [localized_text()]) ->
          return_val().
localize_text(LocalizedTexts) ->
    localize_text(LocalizedTexts, <<"en_US">>).


-spec localize_text/2 ::
          (LocalizedTexts :: [localized_text()],
           Locale :: string()) ->
          return_val().
localize_text(LocalizedTexts, Locale) ->
    localize_text(LocalizedTexts, Locale, default_config()).


-spec localize_text/3 ::
          (LocalizedTexts :: [localized_text()],
           Locale :: string(),
           Config :: aws_config()) ->
          return_val().
localize_text(LocalizedTexts, Locale, Config) ->
    Json = [{<<"locale">>, to_binary(Locale)},
            {<<"localizedTexts">>, [LocalizedTexts]}],
    inspector_request(Config, "InspectorService.LocalizeText", Json).


%%%------------------------------------------------------------------------------
%%% PreviewAgentsForResourceGroup
%%
%% http://docs.aws.amazon.com/inspector/latest/APIReference/API_PreviewAgentsForResourceGroup.html
%%%------------------------------------------------------------------------------

-spec preview_agents_for_resource_group/1 ::
          (ResourceGroupArn :: string()) ->
          return_val().
preview_agents_for_resource_group(ResourceGroupArn) ->
    preview_agents_for_resource_group(ResourceGroupArn, []).


-spec preview_agents_for_resource_group/2 ::
          (ResourceGroupArn :: string(),
           Options :: inspector_opts()) ->
          return_val().
preview_agents_for_resource_group(ResourceGroupArn, Options) ->
    preview_agents_for_resource_group(ResourceGroupArn, Options, default_config()).


-spec preview_agents_for_resource_group/3 ::
          (ResourceGroupArn :: string(),
           Options :: inspector_opts(),
           Config :: aws_config()) ->
          return_val().
preview_agents_for_resource_group(ResourceGroupArn, Options, Config) ->
    OptJson = dynamize_options(Options),
    Json = [{<<"resourceGroupArn">>, to_binary(ResourceGroupArn)}|OptJson],
    inspector_request(Config, "InspectorService.PreviewAgentsForResourceGroup", Json).


%%%------------------------------------------------------------------------------
%%% RegisterCrossAccountAccessRole
%%
%% http://docs.aws.amazon.com/inspector/latest/APIReference/API_RegisterCrossAccountAccessRole.html
%%%------------------------------------------------------------------------------

-spec register_cross_account_access_role/1 ::
          (RoleArn :: string()) ->
          return_val().
register_cross_account_access_role(RoleArn) ->
    register_cross_account_access_role(RoleArn, []).


-spec register_cross_account_access_role/2 ::
          (RoleArn :: string(),
           Options :: inspector_opts()) ->
          return_val().
register_cross_account_access_role(RoleArn, Options) ->
    register_cross_account_access_role(RoleArn, Options, default_config()).


-spec register_cross_account_access_role/3 ::
          (RoleArn :: string(),
           Options :: inspector_opts(),
           Config :: aws_config()) ->
          return_val().
register_cross_account_access_role(RoleArn, Options, Config) ->
    OptJson = dynamize_options(Options),
    Json = [{<<"roleArn">>, to_binary(RoleArn)}|OptJson],
    inspector_request(Config, "InspectorService.RegisterCrossAccountAccessRole", Json).


%%%------------------------------------------------------------------------------
%%% RemoveAttributesFromFindings
%%
%% http://docs.aws.amazon.com/inspector/latest/APIReference/API_RemoveAttributesFromFindings.html
%%%------------------------------------------------------------------------------

-spec remove_attributes_from_findings/2 ::
          (AttributeKeys :: [string()],
           FindingArns :: [string()]) ->
          return_val().
remove_attributes_from_findings(AttributeKeys, FindingArns) ->
    remove_attributes_from_findings(AttributeKeys, FindingArns, default_config()).


-spec remove_attributes_from_findings/3 ::
          (AttributeKeys :: [string()],
           FindingArns :: [string()],
           Config :: aws_config()) ->
          return_val().
remove_attributes_from_findings(AttributeKeys, FindingArns, Config) ->
    Json = [{<<"attributeKeys">>, [to_binary(A) || A <- AttributeKeys]},
            {<<"findingArns">>, [to_binary(F) || F <- FindingArns]}],
    inspector_request(Config, "InspectorService.RemoveAttributesFromFindings", Json).


%%%------------------------------------------------------------------------------
%%% RunAssessment
%%
%% http://docs.aws.amazon.com/inspector/latest/APIReference/API_RunAssessment.html
%%%------------------------------------------------------------------------------

-spec run_assessment/2 ::
          (AssessmentArn :: string(),
           RunName :: string()) ->
          return_val().
run_assessment(AssessmentArn, RunName) ->
    run_assessment(AssessmentArn, RunName, default_config()).


-spec run_assessment/3 ::
          (AssessmentArn :: string(),
           RunName :: string(),
           Config :: aws_config()) ->
          return_val().
run_assessment(AssessmentArn, RunName, Config) ->
    Json = [{<<"assessmentArn">>, to_binary(AssessmentArn)},
            {<<"runName">>, to_binary(RunName)}],
    inspector_request(Config, "InspectorService.RunAssessment", Json).


%%%------------------------------------------------------------------------------
%%% SetTagsForResource
%%
%% http://docs.aws.amazon.com/inspector/latest/APIReference/API_SetTagsForResource.html
%%%------------------------------------------------------------------------------

-spec set_tags_for_resource/2 ::
          (ResourceArn :: string(),
           Tags :: term()) ->
          return_val().
set_tags_for_resource(ResourceArn, Tags) ->
    set_tags_for_resource(ResourceArn, Tags, default_config()).


-spec set_tags_for_resource/3 ::
          (ResourceArn :: string(),
           Tags :: string(),
           Config :: aws_config()) ->
          return_val().
set_tags_for_resource(ResourceArn, Tags, Config) ->
    Json = [{<<"resourceArn">>, to_binary(ResourceArn)},
            {<<"tags">>, Tags}],
    inspector_request(Config, "InspectorService.SetTagsForResource", Json).


%%%------------------------------------------------------------------------------
%%% StartDataCollection
%%
%% http://docs.aws.amazon.com/inspector/latest/APIReference/API_StartDataCollection.html
%%%------------------------------------------------------------------------------

-spec start_data_collection/1 ::
          (AssessmentArn :: string()) ->
          return_val().
start_data_collection(RunArn) ->
    start_data_collection(RunArn, default_config()).


-spec start_data_collection/2 ::
          (AssessmentArn :: term(),
           Config :: aws_config()) ->
          return_val().
start_data_collection(AssessmentArn, Config) ->
    Json = [{<<"assessmentArn">>, to_binary(AssessmentArn)}],
    inspector_request(Config, "InspectorService.StartDataCollection", Json).


%%%------------------------------------------------------------------------------
%%% StopDataCollection
%%
%% http://docs.aws.amazon.com/inspector/latest/APIReference/API_StopDataCollection.html
%%%------------------------------------------------------------------------------

-spec stop_data_collection/1 ::
          (AssessmentArn :: string()) ->
          return_val().
stop_data_collection(RunArn) ->
    stop_data_collection(RunArn, default_config()).


-spec stop_data_collection/2 ::
          (AssessmentArn :: term(),
           Config :: aws_config()) ->
          return_val().
stop_data_collection(AssessmentArn, Config) ->
    Json = [{<<"assessmentArn">>, to_binary(AssessmentArn)}],
    inspector_request(Config, "InspectorService.StopDataCollection", Json).


%%%------------------------------------------------------------------------------
%%% UpdateApplication
%%
%% http://docs.aws.amazon.com/inspector/latest/APIReference/API_UpdateApplication.html
%%%------------------------------------------------------------------------------

-spec update_application/3 ::
          (ApplicationArn :: string(),
           ApplicationName :: string(),
           ResourceGroupArn :: string()) ->
          return_val().
update_application(ApplicationArn, ApplicationName, ResourceGroupArn) ->
    update_application(ApplicationArn, ApplicationName, ResourceGroupArn, default_config()).


-spec update_application/4 ::
          (ApplicationArn :: string(),
           ApplicationName :: string(),
           ResourceGroupArn :: string(),
           Config :: aws_config()) ->
          return_val().
update_application(ApplicationArn, ApplicationName, ResourceGroupArn, Config) ->
    Json = [{<<"applicationArn">>, to_binary(ApplicationArn)},
            {<<"applicationName">>, to_binary(ApplicationName)},
            {<<"resourceGroupArn">>, to_binary(ResourceGroupArn)}],
    inspector_request(Config, "InspectorService.UpdateApplication", Json).


%%%------------------------------------------------------------------------------
%%% UpdateAssessment
%%
%% http://docs.aws.amazon.com/inspector/latest/APIReference/API_UpdateAssessment.html
%%%------------------------------------------------------------------------------

-spec update_assessment/3 ::
          (AssessmentArn :: string(),
           AssessmentName :: string(),
           DurationInSeconds :: integer()) ->
          return_val().
update_assessment(AssessmentArn, AssessmentName, DurationInSeconds) ->
    update_assessment(AssessmentArn, AssessmentName, DurationInSeconds, default_config()).


-spec update_assessment/4 ::
          (AssessmentArn :: string(),
           AssessmentName :: string(),
           DurationInSeconds :: integer(),
           Config :: aws_config()) ->
          return_val().
update_assessment(AssessmentArn, AssessmentName, DurationInSeconds, Config) ->
    Json = [{<<"assessmentArn">>, to_binary(AssessmentArn)},
            {<<"assessmentName">>, to_binary(AssessmentName)},
            {<<"durationInSeconds">>, DurationInSeconds}],
    inspector_request(Config, "InspectorService.UpdateAssessment", Json).


%%%------------------------------------------------------------------------------
%%% Internal Functions
%%%------------------------------------------------------------------------------

inspector_request(Config, Operation, Body) ->
    case erlcloud_aws:update_config(Config) of
        {ok, Config1} ->
            inspector_request_no_update(Config1, Operation, Body);
        {error, Reason} ->
            {error, Reason}
    end.


inspector_request_no_update(Config, Operation, Body) ->
    Payload = case Body of
               <<>> -> <<"{}">>;
               [] -> <<"{}">>;
               _ -> jsx:encode(Body)
           end,
    Headers = headers(Config, Operation, Payload),
    Request = #aws_request{service = inspector,
                           uri = uri(Config),
                           method = post,
                           request_headers = Headers,
                           request_body = Payload},
    case erlcloud_aws:request_to_return(erlcloud_retry:request(Config, Request, fun inspector_result_fun/1)) of
        {ok, {_RespHeaders, <<>>}} -> {ok, []};
        {ok, {_RespHeaders, RespBody}} -> {ok, jsx:decode(RespBody)};
        {error, _} = Error-> Error
    end.


headers(Config, Operation, Body) ->
    Headers = [{"host", Config#aws_config.inspector_host},
               {"x-amz-target", Operation},
               {"content-type", "application/x-amz-json-1.1"}],
    Region = erlcloud_aws:aws_region_from_host(Config#aws_config.inspector_host),
    erlcloud_aws:sign_v4_headers(Config, Headers, Body, Region, "inspector").


uri(#aws_config{inspector_scheme = Scheme, inspector_host = Host} = Config) ->
    lists:flatten([Scheme, Host, port_spec(Config)]).


port_spec(#aws_config{inspector_port=80}) ->
    "";
port_spec(#aws_config{inspector_port=Port}) ->
    [":", erlang:integer_to_list(Port)].


dynamize_options(List) ->
    dynamize_options(List, []).


dynamize_options([{Key, Value}|T], Acc) ->
    DynamizedKey = dynamize_option_key(Key),
    dynamize_options(T, [{DynamizedKey, Value}|Acc]);
dynamize_options([], Acc) ->
    Acc.


dynamize_option_key(Key) when is_atom(Key) ->
    F = fun([A|B], Acc) ->
                C = list_to_binary([string:to_upper(A)|B]),
                <<Acc/binary, C/binary>>
        end,
    lists:foldl(F, <<>>, string:tokens(atom_to_list(Key), "_")).


to_binary(L) when is_list(L) -> list_to_binary(L);
to_binary(B) when is_binary(B) -> B.
