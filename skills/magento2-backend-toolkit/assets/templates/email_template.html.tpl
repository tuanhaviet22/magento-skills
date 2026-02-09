<!--@subject {{trans "Your Subject Here"}} @-->
<!--@vars {
"var customer.name":"Customer Name",
"var order_id":"Order ID",
"var store.frontend_name":"Store Name"
} @-->

{{template config_path="design/email/header_template"}}

<table>
    <tr class="email-intro">
        <td>
            <p class="greeting">{{trans "Hello %name," name=$customer.name}}</p>
            <p>{{trans "Your email content here."}}</p>
        </td>
    </tr>
</table>

{{template config_path="design/email/footer_template"}}
