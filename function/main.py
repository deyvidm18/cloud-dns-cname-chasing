import os
from google.cloud import dns as cloud_dns
import dns.resolver

def update_dns_records(request):
    project_id = os.environ.get("PROJECT_ID")
    zone_name = os.environ.get("ZONE_NAME")
    dns_name = os.environ.get("DNS_NAME")
    cname_target = os.environ.get("CNAME_TARGET")

    try:
        # Resolve the CNAME target using dnspython
        resolver = dns.resolver.Resolver()
        answers = resolver.resolve(cname_target, "A")
        ip_addresses = [str(rdata) for rdata in answers]

        # Add new A records
        if ip_addresses:
            # Update Cloud DNS records
            client = cloud_dns.Client(project=project_id)
            zone = client.zone(zone_name)
            changes = zone.changes()

            # Delete existing records for the dns_name (old method, without filter)
            record_sets = list(zone.list_resource_record_sets()) #No filter allowed on this version
            records_to_delete = []
            for record_set in record_sets:
                if record_set.name == dns_name + ".":  # Filter by name manually
                    records_to_delete.append(record_set)

            for record_set in records_to_delete:
                changes.delete_record_set(record_set)

                # Add new A records
            new_record_set = zone.resource_record_set(dns_name + ".", "A", 300, ip_addresses)
            changes.add_record_set(new_record_set)

            changes.create()
            while changes.status == "pending":
                changes.reload()
            if changes.status == "done":
                print(f"DNS records for {dns_name} updated successfully: {ip_addresses}")
                return f"DNS records for {dns_name} updated successfully: {ip_addresses}", 200

        else:
            print(f"dig command returned no results for {cname_target}")
            return f"dig command returned no results for {cname_target}", 200
    except Exception as e:
        print(f"Error updating DNS records: {e}")
        return f"Error updating DNS records: {e}", 500
