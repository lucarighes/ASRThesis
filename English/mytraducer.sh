#!/usr/bin/env bash

[ -f ./path.sh ] && . ./path.sh; # source the path.
. parse_options.sh || exit 1;

rm -rf	transcription/feats.ark transcription/feats.scp \
	transcription/one-best.tra transcription/one-best-hypothesis.txt \
	transcription/cmvn.scp transcription/cmvn.ark \
	transcription/lat.1.gz \
	transcription/splice-transform-feats.ark transcription/splice-feats.ark \
	transcription/log/*  \
	transcription/splice* \
	transcription/pre_trans.1 transcription/trans.1 transcription/trans_temp.1 \
	transcription/wav.scp #\
	#transcription/test.wav 

if [ $# != 1 ]; then
	echo "-l live decode"
	echo "-f file"
	exit 1;
fi

touch transcription/wav.scp

if [ $1 == -f ]; then
	echo "test /root/kaldi/egs/English/transcription/1089-134686-0000.wav" > transcription/wav.scp
	#echo "test /root/kaldi/egs/English/transcription/test.wav" > transcription/wav.scp
else
	arecord -q -f S16_LE -t wav -r 16000 -d 5 transcription/test.wav #| lame -r -s 16 --decode - - >
	echo "test /root/kaldi/egs/English/transcription/test.wav" > transcription/wav.scp
fi


printf "Compute mfcc feats\n" #    #--allow-downsample=true \
run.pl --max-jobs-run 25 JOB=1 transcription/log/compute_mfcc.JOB.log \
compute-mfcc-feats \
    --config=conf/mfcc.conf \
    scp:transcription/wav.scp \
    ark,scp:transcription/feats.ark,transcription/feats.scp


printf "Compute cmvn\n"
run.pl --max-jobs-run 25 JOB=1 transcription/log/compute_cmvn.JOB.log \
compute-cmvn-stats --spk2utt=ark:transcription/spk2utt \
    scp:transcription/feats.scp \
    ark,scp:transcription/cmvn.ark,transcription/cmvn.scp

printf "Apply cmvn\n"
apply-cmvn --utt2spk=ark:transcription/utt2spk scp:transcription/cmvn.scp scp:transcription/feats.scp ark:- | splice-feats \
	ark: \
        ark:transcription/splice-feats.ark


printf "\nTransform-feats 0\n"
run.pl --max-jobs-run 25 JOB=1 transcription/log/transform_feats0.JOB.log \
transform-feats \
	exp/tri4b/final.mat \
        ark:transcription/splice-feats.ark \
        ark:transcription/splice-transform-feats0.ark


printf "LDA+MLLT performing...\n"
run.pl --max-jobs-run 25 JOB=1 transcription/log/lda_mllt.JOB.log \
gmm-latgen-faster --max-active=7000 --beam=13.0 --lattice-beam=6.0 --acoustic-scale=0.083333 --allow-partial=true --word-symbol-table=exp/tri4b/graph/words.txt exp/tri4b/final.mdl exp/tri4b/graph/HCLG.fst "ark:transcription/splice-transform-feats0.ark" "ark:|gzip -c > transcription/lat.1.gz"

run.pl --max-jobs-run 25 JOB=1 transcription/log/lattice1.JOB.log \
lattice-best-path \
    --word-symbol-table=exp/tri4b/graph/words.txt \
    "ark:gunzip -c transcription/lat.1.gz|" \
    ark,t:transcription/one-best.tra

utils/int2sym.pl -f 2- \
    exp/tri4b/graph/words.txt \
    transcription/one-best.tra \
    > transcription/one-best-hypothesis.txt

printf "LDA+MLLT Result: "
cat transcription/one-best-hypothesis.txt

rm transcription/one-best-hypothesis.txt
###########################STA##########################

printf "\nFirst-pass fMLLR \n"
run.pl --max-jobs-run 25 JOB=1 transcription/log/fmllr_pass1.JOB.log \
    gunzip -c transcription/lat.1.gz \| \
    lattice-to-post --acoustic-scale=0.083333 ark:- ark:- \| \
    weight-silence-post 0.01 1:2:3:4:5:6:7:8:9 exp/tri4b/final.mdl ark:- ark:- \| \
    gmm-post-to-gpost exp/tri4b/final.mdl ark:transcription/splice-transform-feats0.ark ark:- ark:- \| \
    gmm-est-fmllr-gpost --fmllr-update-type=full \
    --spk2utt=ark:transcription/spk2utt exp/tri4b/final.mdl ark:transcription/splice-transform-feats0.ark ark,s,cs:- \
    ark:transcription/pre_trans.JOB;

printf "Transform-feats 1\n"
run.pl --max-jobs-run 25 JOB=1 transcription/log/transform_feats1.JOB.log \
transform-feats \
	--utt2spk=ark:transcription/utt2spk \
	ark:transcription/pre_trans.1 \
        ark:transcription/splice-transform-feats0.ark \
	ark:transcription/splice-transform-feats1.ark

printf "Main lattice generation... "
run.pl --max-jobs-run 25 JOB=1 transcription/log/lattice_gen.JOB.log \
gmm-latgen-faster --max-active=7000 --beam=13.0 --lattice-beam=6.0 \
    --acoustic-scale=0.083333 --determinize-lattice=false \
    --allow-partial=true --word-symbol-table=exp/tri4b/graph/words.txt \
    exp/tri4b/final.mdl exp/tri4b/graph/HCLG.fst "ark:transcription/splice-transform-feats1.ark" "ark:|gzip -c > transcription/lat.tmp.1.gz"


printf "DONE\n"


run.pl --max-jobs-run 25 JOB=1 transcription/log/fmllr_pass2.JOB.log \
    lattice-determinize-pruned --acoustic-scale=0.083333 --beam=4.0 \
    "ark:gunzip -c transcription/lat.tmp.1.gz |" ark:- \| \
    lattice-to-post --acoustic-scale=0.083333 ark:- ark:- \| \
    weight-silence-post 0.01 1:2:3:4:5:6:7:8:9 exp/tri4b/final.mdl ark:- ark:- \| \
    gmm-post-to-gpost exp/tri4b/final.mdl ark:transcription/splice-transform-feats1.ark ark:- ark:- \| \
    gmm-est-fmllr-gpost --fmllr-update-type=full \
    --spk2utt=ark:transcription/spk2utt exp/tri4b/final.mdl ark:transcription/splice-transform-feats1.ark ark,s,cs:- \
    ark:transcription/trans_tmp.JOB  '&&' \
    compose-transforms --b-is-affine=true ark:transcription/trans_tmp.JOB ark:transcription/pre_trans.JOB \
    ark:transcription/trans.JOB 

printf "Transform-feats 2\n"
run.pl --max-jobs-run 25 JOB=1 transcription/log/transform_feats2.JOB.log \
transform-feats \
	--utt2spk=ark:transcription/utt2spk \
	ark:transcription/trans.1 \
        ark:transcription/splice-transform-feats1.ark \
	ark:transcription/splice-transform-feats2.ark

printf "Rescore lattice\n"
run.pl --max-jobs-run 25 JOB=1 transcription/log/fmllr_pass3.JOB.log \
    gmm-rescore-lattice exp/tri4b/final.mdl "ark:gunzip -c transcription/lat.tmp.1.gz|" "ark:transcription/splice-transform-feats2.ark" ark:- \| \
    lattice-determinize-pruned --acoustic-scale=0.083333 --beam=13.0 ark:- \
    "ark:|gzip -c > transcription/lat.2.gz" '&&' rm transcription/lat.tmp.JOB.gz

run.pl --max-jobs-run 25 JOB=1 transcription/log/lattice2.JOB.log \
lattice-best-path \
    --word-symbol-table=exp/tri4b/graph/words.txt \
    "ark:gunzip -c transcription/lat.2.gz|" \
    ark,t:transcription/one-best.tra

utils/int2sym.pl -f 2- \
    exp/tri4b/graph/words.txt \
    transcription/one-best.tra \
    > transcription/one-best-hypothesis.txt

printf "\nFILE RESULT\n"
if [ $1 == -f ]; then
	printf "EXPECTED test HE HOPED THERE WOULD BE STEW FOR DINNER TURNIPS AND CARROTS AND BRUISED POTATOES AND FAT MUTTON PIECES TO BE LADLED OUT IN THICK PEPPERED FLOUR FATTENED SAUCE\n"
fi
printf "RESULT   "
cat transcription/one-best-hypothesis.txt
