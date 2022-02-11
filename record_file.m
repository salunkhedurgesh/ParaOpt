function [save_files] = record_file()
    format shortg
    c = clock;
    month_list = ["Jan", "Feb", "mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    mmonth = month_list(c(2));
    file1 = "deep_record_" + num2str(c(3)) + mmonth + "_" + num2str(c(4)) + "hrs_" + num2str(c(5)) + "min" + ".txt";
    file2 = "points_record_" + num2str(c(3)) + mmonth + "_" + num2str(c(4)) + "hrs_" + num2str(c(5)) + "min" + ".txt";
    file3 = "refine_record_" + num2str(c(3)) + mmonth + "_" + num2str(c(4)) + "hrs_" + num2str(c(5)) + "min" + ".txt";
    file4 = "quality_record_" + num2str(c(3)) + mmonth + "_" + num2str(c(4)) + "hrs_" + num2str(c(5)) + "min" + ".txt";

    save_files = [file1, file2, file3, file4]; 
end