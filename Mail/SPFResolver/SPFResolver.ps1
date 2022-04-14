param(
    [string]$Domain,
    [switch]$expandResults
)

function Start-SPFResolver($Domain) {
Add-Type -assemblyName PresentationFramework
Add-Type -assemblyName System.Windows.Forms

[xml]$xaml = @"
<Window x:Class="SPFResolver.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:SPFResolver"
        mc:Ignorable="d"
        Title="SPF-Resolver" Height="565" Width="625" WindowStartupLocation="CenterScreen" ResizeMode="NoResize">
    <Grid Background="White">
        <Label Content="Domain" HorizontalAlignment="Left" Margin="10,101,0,0" VerticalAlignment="Top"/>
        <TextBox x:Name="domain_box" Height="24" Margin="67,103,0,0" TextWrapping="Wrap" VerticalAlignment="Top" HorizontalAlignment="Left" Width="153"/>
        <TreeView x:Name="result_tview" HorizontalAlignment="Left" Height="341" Margin="10,160,0,0" VerticalAlignment="Top" Width="599"/>
        <Button x:Name="resolve_btn" Content="Resolve" HorizontalAlignment="Left" Margin="540,105,0,0" VerticalAlignment="Top" Width="75" Height="24"/>
        <Button x:Name="expand_btn" Content="Expand all" HorizontalAlignment="Left" Margin="534,506,0,0" VerticalAlignment="Top" Width="75"/>
        <Label x:Name="info_txt" Content="The listed clients are authorized to send mails on behalf of the domain." HorizontalAlignment="Left" Margin="10,129,0,0" VerticalAlignment="Top"/>
        <Label x:Name="domain_info" Content="..." HorizontalAlignment="Left" Margin="400,129,0,0" VerticalAlignment="Top" FontWeight="Bold"/>
        <Rectangle Fill="#FF000074" HorizontalAlignment="Left" Height="54" Stroke="Black" VerticalAlignment="Top" Width="620" RenderTransformOrigin="0.5,0.5" Margin="0,0,-1,0">
            <Rectangle.RenderTransform>
                <TransformGroup>
                    <ScaleTransform ScaleY="-1"/>
                    <SkewTransform/>
                    <RotateTransform/>
                    <TranslateTransform/>
                </TransformGroup>
            </Rectangle.RenderTransform>
        </Rectangle>
        <TextBox HorizontalAlignment="Left" Height="37" Margin="10,60,0,0" TextWrapping="Wrap" Text="This tool searches for TXT SPF entries of a domain. The entries are resolved up to the ip4 or a entries. This allows you to trace include entries within a SPF entry." VerticalAlignment="Top" Width="605" IsReadOnly="True"/>
        <Label Content="SPF Resolver" HorizontalAlignment="Left" Margin="10,10,0,0" VerticalAlignment="Top" FontSize="18" Foreground="White"/>
    </Grid>
</Window>
"@ -replace 'mc:Ignorable="d"','' -replace "x:N",'N' -replace '^<Win.*', '<Window'

[xml]$wait_xaml = @"
<Window x:Class="SPFResolver.Wait"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:SPFResolver"
        mc:Ignorable="d"
        Title="Wait" Height="113.627" Width="327.709" WindowStartupLocation="CenterScreen" Topmost="True" ResizeMode="NoResize">
    <Grid>
        <Label Content="Please wait....." HorizontalAlignment="Left" Margin="10,10,0,0" VerticalAlignment="Top"/>
        <Label Content="Resolving SPF records for domain $domainBox" HorizontalAlignment="Left" Margin="10,41,0,0" VerticalAlignment="Top" RenderTransformOrigin="0.439,0.385"/>
    </Grid>
</Window>
"@ -replace 'mc:Ignorable="d"','' -replace "x:N",'N' -replace '^<Win.*', '<Window'

$reader=(New-Object System.Xml.XmlNodeReader $xaml)
$w=[Windows.Markup.XamlReader]::Load( $reader )

$info = $w.FindName("domain_info")
$tview = $w.FindName("result_tview")
$domainBox = $w.FindName("domain_box")
$netBox = $w.FindName("calculateNet_box")

$w.FindName("resolve_btn").add_click({
    function Add-TreeItem($Name,$Parent,$Tag) {
        $ChildItem = New-Object System.Windows.Controls.TreeViewItem
        $ChildItem.Header = $Name
        $ChildItem.Name = "i"
        $ChildItem.Tag = "$Tag\$Name"
        [Void]$Parent.Items.Add($ChildItem)
        return $ChildItem
    }
    
    function Resolve-Include($record, $item, $root) {
        if($root -eq $true) {
            $item = Add-TreeItem -Name $record -Parent $item -Tag "r"
        } else {
            $item = Add-TreeItem -Name "include:$($record)" -Parent $item -Tag "r"
        }
        
        $dns_result = Resolve-DnsName $record -Type TXT -ErrorAction Ignore
        
        if($dns_result -eq $null) {
            $item3 = Add-TreeItem -Name "Can not find an appropriate TXT record" -Parent $item -Tag "r"
        }

        $spf_record = ($dns_result | where strings -like "*v=spf1*").Strings
        $has_includes = [Regex]::Matches($spf_record, "include:(\w[a-z0-9-.\-_]+)")
        if($dns_result -ne $null) {
            foreach($v in [regex]::matches($spf_record, "(ip4:[0-9\.\/]+)").value) {
                if([regex]::Matches($v, "(\/\d+)").Success -eq $true -and $netBox.IsChecked -eq $true) {
                    $item3 = Add-TreeItem -Name "$v (allowed hosts: $($ip.count))" -Parent $item -Tag "r"
                    <#foreach($i in $ip) {
                        $item2 = Add-TreeItem -Name "host:$i" -Parent $item3 -Tag "r"
                    }#>
                } else {
                    $item3 = Add-TreeItem -Name "$v" -Parent $item -Tag "r"
                }
            }
            foreach($v in [regex]::matches($spf_record, "(a:\w*.\w*.\w*.\w*)").value) {
                $item3 = Add-TreeItem -Name $v -Parent $item -Tag "r"
            }
        }
        foreach($include in $has_includes.Value) {
            Resolve-Include -record $include.Replace("include:","") -item $item -root $false
        }
    }
    $reader2=(New-Object System.Xml.XmlNodeReader $wait_xaml)
    $w2=[Windows.Markup.XamlReader]::Load( $reader2 )
    $w2.Show()
    $tview.Items.Clear()
    Resolve-Include -record $domainBox.Text -item $tview -root $true
    $info.Content = "$($domainBox.Text)"
    $w2.Close()
})

$w.FindName("expand_btn").add_click({
    foreach($item in $tview.Items) {
        [System.Windows.Controls.TreeViewItem]$item.ExpandSubTree()
    }
})

if($domain) {
    $domainBox.Text = $domain
    $w.FindName("resolve_btn").RaiseEvent((New-Object -TypeName System.Windows.RoutedEventArgs -ArgumentList $([System.Windows.Controls.Button]::ClickEvent)))
    if($expandResults) {
        $w.FindName("expand_btn").RaiseEvent((New-Object -TypeName System.Windows.RoutedEventArgs -ArgumentList $([System.Windows.Controls.Button]::ClickEvent)))
    }
}

$w.ShowDialog() | out-null

}

Start-SPFResolver -Domain $domain
