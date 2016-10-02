function frq_est=frequency_estimate_shrn(s4fes2,s4fes3,a4fesx,a4fesy,a4fesz,HR0,mltplr)
    frq_est1=-1;
    frq_est2=-1;
    ch1=time_domain_shrn(s4fes2,a4fesx,a4fesy,a4fesz,mltplr);
    ch2=time_domain_shrn(s4fes3,a4fesx,a4fesy,a4fesz,mltplr);

    if(length(ch1)~=1)
        w=linspace(0,200,1000);
        w=(w/(125*60*mltplr))*2*pi;

        yy1=ch1;
        yy1=abs(freqz(yy1,1,w)).^2;
        [faul1,loc]=findpeaks(yy1,'Sortstr','descend');

        w=w(loc);
        w=(w*125*60*mltplr)/(2*pi);
        [faul,loc]=min(abs(w-HR0));
        frq_est1=w(loc);
    end
    if(length(ch2)~=1)

        w=linspace(0,200,1000);
        w=(w/(125*60*mltplr))*2*pi;
        yy2=ch2;
        yy2=abs(freqz(yy2,1,w)).^2;
        [faul2,loc]=findpeaks(yy2,'Sortstr','descend');

        w=w(loc);
        w=(w*125*60*mltplr)/(2*pi);
        [faul,loc]=min(abs(w-HR0));
        frq_est2=w(loc);
    end

    frq_est=-1;

    bd=12;

    if (abs(frq_est1-HR0)<=bd && abs(frq_est2-HR0)<=bd)
        if(abs(frq_est1-HR0)<abs(frq_est2-HR0))
            frq_est=frq_est1;
        else
            frq_est=frq_est2;
        end

    elseif (abs(frq_est1-HR0)<=bd)
        frq_est=frq_est1;

    elseif (abs(frq_est2-HR0)<=bd)
        frq_est=frq_est2;

    end

end