# plugin activation
$c->{plugins}->{"EdShareToolbox"}->{params}->{disable} = 0;
$c->{plugins}{"Convert::OfficePreview"}{params}{disable} = 0;
$c->{plugins}->{"Export::Zip"}->{params}->{disable} = 0;
$c->{plugins}->{"InputForm::Component::Field::TagLite"}->{params}->{disable} = 0;
$c->{plugins}->{"TagLiteSuggestionList::MostPopularUserTags"}->{params}->{disable} = 0;
$c->{plugins}->{"TagLiteSuggestionList::StaticTags"}->{params}->{disable} = 0;
$c->{plugins}->{"InputForm::Component::Permissions"}->{params}->{disable} = 0;
$c->{plugins}->{"PermissionType::Creators"}->{params}->{disable} = 0;
$c->{plugins}->{"PermissionType::UserLookup"}->{params}->{disable} = 0;
#  $c->{plugins}->{"TagCloud"}->{params}->{disable} = 0;
$c->{plugins}->{"Screen::BrowseViews"}->{params}->{disable} = 0;
$c->{plugins}->{"Screen::EPrint::EdShareEdit"}->{params}->{disable} = 0;
$c->{plugins}->{"Screen::EPrint::EdShareChangeOwner"}->{params}->{disable} = 0;
$c->{plugins}->{"Screen::EPrint::EdShareViewRedirect"}->{params}->{disable} = 0;
$c->{plugins}->{"Screen::EPrint::EmailAuthor"}->{params}->{disable} = 0;
$c->{plugins}->{"Screen::EPrint::ExportZip"}->{params}->{disable} = 0;
$c->{plugins}->{"Screen::EPrint::RedoThumbnails"}->{params}->{disable} = 1;
$c->{plugins}->{"Screen::RedirectingLogin"}->{params}->{disable} = 0;

#resource manager
$c->{plugins}->{"Screen::ResourceManager"}->{params}->{disable} = 0;
$c->{plugins}->{"ResourceManagerFilter"}->{params}->{disable} = 0; 
$c->{plugins}->{"Screen::BulkAction"}->{params}->{disable} = 0; 
$c->{plugins}->{"Screen::BulkAction::Collection"}->{params}->{disable} = 0; 
$c->{plugins}->{"Screen::BulkAction::Remove"}->{params}->{disable} = 0; 

#plugin removal
$c->{plugins}->{"Screen::Review"}->{params}->{disable} = 1;
$c->{plugins}->{"Screen::EPrint::Document::Extract"}->{params}->{disable} = 1;
$c->{plugins}->{"Screen::EPrint::Document::Convert"}->{params}->{disable} = 1;
$c->{plugins}->{"Screen::EPrint::Document::Files"}->{params}->{disable} = 1;
$c->{plugins}->{"Screen::EPrint::UploadMethod::URL"}->{params}->{disable} = 1;

# plugin alias
$c->{plugin_alias_map}->{"Screen::EPrint::Edit"} = "Screen::EPrint::EdShareEdit";
$c->{plugin_alias_map}->{"Screen::EPrint::EdShareEdit"} = undef;

$c->{plugin_alias_map}->{"Screen::EPrint::Staff::ChangeOwner"} = "Screen::EPrint::EdShareChangeOwner";
$c->{plugin_alias_map}->{"Screen::EPrint::EdShareChangeOwner"} = undef;

$c->{plugin_alias_map}->{"Screen::Login"} = "Screen::RedirectingLogin";
$c->{plugin_alias_map}->{"Screen::EPrint::RedirectingLogin"} = undef;

$c->{plugin_alias_map}->{"Screen::EPrint::View"} = "Screen::EPrint::EdShareViewRedirect";

$c->{plugin_alias_map}->{"Screen::Items"} = "Screen::ResourceManager";
$c->{plugins}->{"Screen::Items"}->{appears}->{key_tools} = undef;

# toolbar stuff
$c->{plugins}->{"Screen::EPrint::ShowLock"}->{appears}->{edshare_toolbox} = 0;
$c->{plugins}->{"Screen::EPrint::Edit"}->{appears}->{edshare_toolbox} = 10;
$c->{plugins}->{"Screen::EPrint::Remove"}->{appears}->{edshare_toolbox} = 20;
$c->{plugins}->{"Screen::EPrint::Staff::ChangeOwner"}->{appears}->{edshare_toolbox} = 40;
$c->{plugins}->{"Screen::EPrint::ExportZip"}->{appears}->{edshare_toolbox} = 50;
$c->{plugins}->{"Screen::EPrint::EmailAuthor"}->{appears}->{edshare_toolbox} = 60;

$c->{plugins}->{"Screen::BrowseViews"}->{appears}->{key_tools} = 400;
$c->{plugins}->{"Screen::ResourceManager"}->{appears}->{key_tools} = 100;
